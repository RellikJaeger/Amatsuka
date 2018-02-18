# Amatsuka

![amatsuka](https://38.media.tumblr.com/3249e7c1e5e56fa32ea0d2dc29de3be2/tumblr_n54i8vGyOT1s4qvrdo1_500.gif)

from <a href="http://ikaotaku.tumblr.com/post/84866426652" target="_blank">ikaotaku.tumblr.com/post/84866426652</a>

# What's this

Twitter Client - Viewer for Image.

![demo](https://github.com/eiurur/Amatsuka/raw/master/demo.gif)

# 動機

* Twitter でも pixiv と同じくらい気軽に絵師をフォローしたい
* 絵師のイラストを効率的に閲覧・収集したい

# 仕組み

このサービスは Twitter 認証を行うと、まず初めに「Amatsuka」という名前のプライベートリストを作成します。

そのリストのメンバーが Twitter でいうホームタイムラインとして扱われます。

各所に設置されたフォローボタンが押された場合、そのリストへユーザが追加されていきます。

これにより、自分のホームタイムラインが煩雑にならずに済むため、今後のことに悩むことなくフォローを行えます。

また、リストは公式のものであるため、Twitter web や、The world といった非公式クライアントからでも操作、閲覧が可能です。

# Site

<a href="https://amatsuka.herokuapp.com/" target="_blank">Amatsuka - heroku</a>

# Feature

* [x] Login with Twitter
* [x] Show tweets in Amatsuka's list
* [x] Add to list
* [x] Fav
* [x] Retweet
* [x] Download
* [x] Filtering with name for list's members
* [x] List up own favorite tweets
* [x] List up own lists
* [ ] List up tweets in own lists
* [x] Show individually user data and tweet
* [x] Zoom up a image
* [x] Masonry
* [ ] Streaming
* [x] Block
* [x] Mute
* [ ] Suggest user
* [x] config
* [x] Toggle the tpye of display (only user's tweet or include retweet)
* [x] Download multiple images

# Development

① プロジェクトをローカルに落とします。

    git clone https://github.com/eiurur/Amatsuka
    cd Amatsuka
    npm i

② 設定ファイルをリネームします。

    mv src/lib/configs/development.coffee.example src/lib/configs/development.coffee

③ `src/lib/configs/development.coffee`の中の次の設定値をご自身のモノに変更してください。

    TW_CK         = 'YOUR_TWITTER_CONSUMER_KEY'
    TW_CS         = 'YOUR_TWITTER_CONSUMER_SECRET'
    TW_AT         = 'YOUR_TWITTER_ACCESS_TOKEN'
    TW_AS         = 'YOUR_TWITTER_ACCESS_TOKEN_SECRET'
    TW_ID_STR     = 'YOUR_TWITTER_ID_STR'

④ ビルドします。

    npm run build

⑤ アプリケーションを立ち上げます。

    npm run dev
