angular.module "myApp.directives"
  .directive 'listLayoutTweet', ->
    restrict: 'E'
    scope: {}
    template: """

    <div class="timeline__post--header">
      <div class="timeline__post--header--info">
        <div class="timeline__post--header--link">
          <span twitter-id-str="{{::$ctrl.tweet.user.id_str}}" show-drawer="show-drawer" class="timeline__post--header--user clickable">{{::$ctrl.tweet.user.screen_name}}
          </span>
          <span ng-if="$ctrl.tweet.retweeted_status" class="timeline__post--header--rt_icon">
            <i class="fa fa-retweet"></i>
          </span>
          <a twitter-id-str="{{::$ctrl.tweet.retweeted_status.user.id_str}}" show-drawer="show-drawer" class="timeline__post--header--rt_source">{{::$ctrl.tweet.retweeted_status.user.screen_name}}
          </a>
          <followable ng-if="!$ctrl.tweet.followStatus" list-id-str="{{$ctrl.listIdStr}}" tweet="{{$ctrl.tweet}}" follow-status="$ctrl.tweet.followStatus">
          </followable>
        </div>
      </div>
      <div class="timeline__post--header--time"><a href="https://{{::$ctrl.tweet.sourceUrl}}" target="_blank">{{::$ctrl.tweet.time}}
        </a>
      </div>
    </div>
    <div class="timeline__post--icon"><img ng-src="{{::$ctrl.tweet.user.profile_image_url_https}}" img-preload="img-preload" show-drawer="show-drawer" twitter-id-str="{{::$ctrl.tweet.user.id_str}}" class="fade"/>
    </div>
    <div ng-repeat="picUrl in $ctrl.tweet.picUrlList" class="timeline__post--image">
      <img ng-if="!$ctrl.tweet.video_url" ng-src="{{::picUrl}}" img-preload="img-preload" zoom-image="zoom-image" data-img-src="{{::picUrl}}" class="fade"/>
      <video ng-if="$ctrl.tweet.video_url" poster="{{::picUrl}}" controls="controls" muted="muted">
        <source ng-src="{{::$ctrl.tweet.video_url | trusted}}" type="video/mp4">
        </source>
      </video>
    </div>
    <div ng-if="!config.isShowOnlyImage" class="timeline__post__text__container">
      <div ng-if="!$ctrl.tweet.retweeted_status" ng-bind-html="$ctrl.tweet.text | newlines" class="timeline__post--text">
      </div>
      <div ng-if="$ctrl.tweet.retweeted_status" class="timeline__post--blockquote">
        <p><a twitter-id-str="{{::$ctrl.tweet.retweeted_status.user.id_str}}" show-drawer="show-drawer">{{::$ctrl.tweet.retweeted_status.user.screen_name}}
          </a>
        </p>
        <blockquote>
          <div ng-bind-html="$ctrl.tweet.text | newlines" class="timeline__post--text">
          </div>
        </blockquote>
      </div>
    </div>
    <div class="timeline__post--footer">
      <div class="timeline__post--footer--contents">
        <div class="timeline__post--footer--contents--controls">
          <i retweet-num="$ctrl.tweet.retweetNum" retweeted="$ctrl.tweet.retweeted" tweet-id-str="{{::$ctrl.tweet.tweetIdStr}}" retweetable="retweetable" class="fa fa-retweet icon-retweet">{{$ctrl.tweet.retweetNum}}</i>
          <i fav-num="$ctrl.tweet.favNum" favorited="$ctrl.tweet.favorited" tweet-id-str="{{::$ctrl.tweet.tweetIdStr}}" favoritable="favoritable" class="fa fa-heart icon-heart">{{$ctrl.tweet.favNum}}</i>
          <a>
            <i data-url="{{::$ctrl.tweet.extended_entities.media[0].media_url}}:orig" filename="{{::$ctrl.tweet.fileName}}" download-from-url="download-from-url" class="fa fa-download"></i>
          </a>
        </div>
      </div>
    </div>

    """
    bindToController:
      tweet: "="
      listIdStr: "="
    controllerAs: "$ctrl"
    controller: ListLayoutTweet

class ListLayoutTweet
  constructor: () ->
    console.log @
