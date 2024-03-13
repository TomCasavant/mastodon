Mastodon/Glitch fork that attempts to remove hashtags from users posts but keeps the tag persistent

The tags are removed from the post but kept inside the activitypub tags if the tags are located at the bottom of the post. Otherwise the hashtag remains
Currently being run at [https://tomkahe.com](https://tomkahe.com)

Modified an android client to handle editing posts (still need to make changes to the web-ui). The android client will append the tags when you open up the edit window [tomcasavant/moshidon](https://github.com/TomCasavant/moshidon)

## TODO:

- Editing a post in the web-ui will remove the hashtags from the activitypub activity and it's not clear to the user. Ideally when the user edits a post the hashtags will be appended to the end of their editing window (This is now fixed for an android client)
- Hide in-line hashtags but keep their links. e.g. "Posting from #mastodon" -> "Posting from <a href='#mastodon'>mastodon</a>" but current experiments with that link to the specific instance where the post originates which would be a bad experience
- Hide tags from other users posts (do not edit the activity, just when the tags are _displayed_ a user of the instance)
- Editing a post will remove all tag associations

## Original README

---

# Mastodon Glitch Edition

> Now with automated deploys!

[![Build Status](https://img.shields.io/circleci/project/github/glitch-soc/mastodon.svg)][circleci]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/glitch-soc/mastodon.svg)][code_climate]

[circleci]: https://circleci.com/gh/glitch-soc/mastodon
[code_climate]: https://codeclimate.com/github/glitch-soc/mastodon

So here's the deal: we all work on this code, and anyone who uses that does so absolutely at their own risk. can you dig it?

- You can view documentation for this project at [glitch-soc.github.io/docs/](https://glitch-soc.github.io/docs/).
- And contributing guidelines are available [here](CONTRIBUTING.md) and [here](https://glitch-soc.github.io/docs/contributing/).
