---
layout: default
title: 過去のダッシュボード
---

# 過去のダッシュボード

<ul>
{% for post in site.posts %}
  <li><a href="{{ post.url | relative_url }}">{{ post.date | date: "%Y-%m-%d (%a)" }}</a> — {{ post.location }}</li>
{% endfor %}
</ul>
