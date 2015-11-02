window.ClientApp.controller 'TrelloController', ($scope, $http, $attrs) ->
  $scope.boards = []
  $scope.chatId = $attrs.chatId
  $scope.callbackUrl = $attrs.callbackUrl

  $scope.init = () ->
    authenticationSuccess = ->
      console.log 'successful auth'

      $scope.loadBoards()

    authenticationFailure = ->
      console.log 'auth failure'

    Trello.authorize(
      type: "redirect",
      name: "Hackwrench",
      persist: true,
      scope: {
        read: true,
        write: false
      },
      # webhooks are linked to tokens, if the token expires, so do webhooks
      expiration: "never",
      success: authenticationSuccess,
      error: authenticationFailure
    )

  $scope.loadBoards = ->
    Trello.rest('GET', 'members/me/boards', {},
      (boards) ->
        $scope.$apply ->
          $scope.boards = boards

        loadWebhooks()
    , () ->
      console.log 'failed to fetch boards'
    )

  loadWebhooks = ->
    Trello.rest('GET', "tokens/#{Trello.token()}/webhooks", {},
      (webhooks) ->
        console.log 'webhooks loaded'
        $scope.$apply ->
          for b in $scope.boards
            webhook = (w for w in webhooks when w.idModel == b.id)[0] || null
            b.webhookEnabled = webhook != null && webhook.callbackURL == $scope.callbackUrl

            if b.webhookEnabled
              b.webhookId = webhook.id
      , () ->
        console.log 'failed to load webhooks'
    )

  $scope.toogleWebhook = (board) ->
    if board.webhookEnabled
      Trello.rest('POST', 'webhooks', {idModel: board.id, callbackURL: $scope.callbackUrl},
        (webhook) ->
          console.log 'created webhook'
          board.webhookId = webhook.id
          enabledNotifications(board)
        , () ->
          console.log 'failed to created webhook')
    else
      Trello.rest('DELETE', "webhooks/#{board.webhookId}", {},
        (webhook) ->
          console.log 'deleted webhook'
          delete board.webhookId
          disabledNotifications(board)
        , () ->
          console.log 'failed to delete webhook')

  enabledNotifications = (board) ->
    $http.post('/client/chats/' + $scope.chatId + '/trello/webhook_enabled', board_name: board.name)

  disabledNotifications = (board) ->
    $http.post('/client/chats/' + $scope.chatId + '/trello/webhook_disabled', board_name: board.name)

  $scope.init()