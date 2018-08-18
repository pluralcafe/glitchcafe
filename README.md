![Mastodon](https://i.imgur.com/NhZc40l.png)
========

[![Build Status](https://img.shields.io/circleci/project/github/tootsuite/mastodon.svg)][circleci]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/tootsuite/mastodon.svg)][code_climate]

[circleci]: https://circleci.com/gh/tootsuite/mastodon
[code_climate]: https://codeclimate.com/github/tootsuite/mastodon

Mastodon is a **free, open-source social network server** based on **open web protocols** like ActivityPub and OStatus. The social focus of the project is a viable decentralized alternative to commercial social media silos that returns the control of the content distribution channels to the people. The technical focus of the project is a good user interface, a clean REST API for 3rd party apps and robust anti-abuse tools.

**Ruby on Rails** is used for the back-end, while **React.js** and Redux are used for the dynamic front-end. A static front-end for public resources (profiles and statuses) is also provided.

This repository specifically is for [Plural Café](https://plural.cafe) and has three branches:

* **master** (**edge** on Docker Hub) for all development and staging work,
* **glitch** for all commits from upstream that will automatically be synched to this repository, and
* **production** (**latest** on Docker Hub) for what goes onto the main website.

In addition, there are several repositories in this GitHub organization:

* **pluralcafe/mastodon** is this repository and is the codebase for what Plural Café runs,
* [**pluralcafe/utils**](https://github.com/pluralcafe/utils) are an assortment of scripts and tutorials to help in Mastodon system administration or general helper files this instance uses,
* [**pluralcafe/barkeep**](https://github.com/pluralcafe/barkeep) is forked from [mbilokonsky/ambassador](https://github.com/mbilokonsky/ambassador) and serves as the Ambassador bot that is run on the instance.

This instance is a fork of a fork: this has the [Mastodon Glitch Edition](https://github.com/glitch-soc/mastodon) commits. Documentation for Mastodon Glitch Edition [can be found here](https://glitch-soc.github.io/docs/). Anyone wishing to use Glitch Edition in a Docker image for their own site can use the `pluralcafe/mastodon:glitch` image.

---

## Resources

- [Frequently Asked Questions](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md)
- [Use this tool to find Twitter friends on Mastodon](https://bridge.joinmastodon.org)
- [API overview](https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md)
- [List of Mastodon instances](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/List-of-Mastodon-instances.md)
- [List of apps](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md)
- [List of sponsors](https://joinmastodon.org/sponsors)

## Features

**No vendor lock-in: Fully interoperable with any conforming platform**

It doesn't have to be Mastodon, whatever implements ActivityPub or OStatus is part of the social network!

**Real-time timeline updates**

See the updates of people you're following appear in real-time in the UI via WebSockets. There's a firehose view as well!

**Federated thread resolving**

If someone you follow replies to a user unknown to the server, the server fetches the full thread so you can view it without leaving the UI

**Media attachments like images and short videos**

Upload and view images and WebM/MP4 videos attached to the updates. Videos with no audio track are treated like GIFs; normal videos are looped - like vines!

**OAuth2 and a straightforward REST API**

Mastodon acts as an OAuth2 provider so 3rd party apps can use the API

**Fast response times**

Mastodon tries to be as fast and responsive as possible, so all long-running tasks are delegated to background processing

**Deployable via Docker**

You don't need to mess with dependencies and configuration if you want to try Mastodon, if you have Docker and Docker Compose the deployment is extremely easy

