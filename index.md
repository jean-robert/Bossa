---
layout: default
title: Bossa
---


{% assign first_post = site.posts.first %}

# Latest song - {{ first_post.title }} #

{{ first_post.content }}


[Read More &raquo;]({{ first_post.url}})
