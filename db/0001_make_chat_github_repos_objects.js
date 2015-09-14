var chats = db.chats.find().forEach(function(c) {
  if (typeof c.github_repos === 'undefined') {
    return;
  }

  print (c._id);
  c.github_repos.forEach(function(r) {
    if (typeof r == 'string') {
      print("Repo " + r);

      var rObj = {name: r, created_on_webhook: false, disabled: false};

      print("Adding a new obj");
      c.github_repos.push(rObj);

      print("Removing an old string");
      c.github_repos.splice(c.github_repos.indexOf(r), 1);

      db.chats.save(c);
    }
  })
});