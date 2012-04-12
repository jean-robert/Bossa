---
layout: default
title: Cool Songs
---


# Cool Songs #

<ul class="post-list">
{% for post in site.posts %}
  <li><a href="/Bossa{{ post.url }}">{{ post.title }}</a> <span class="date">( {{ post.date | date: "%b %Y" }} )</span></li>
{% endfor %}     
</ul>

