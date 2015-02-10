/* ng-infinite-scroll - v1.1.0 - 2014-04-03 */
var mod;
mod = angular.module("infinite-scroll", []), mod.value("THROTTLE_MILLISECONDS", null), mod.directive("infiniteScroll", ["$rootScope", "$window", "$timeout", "THROTTLE_MILLISECONDS", function(n, i, l, e) {
    return {
        scope: {
            infiniteScroll: "&",
            infiniteScrollContainer: "=",
            infiniteScrollDistance: "=",
            infiniteScrollDisabled: "="
        },
        link: function(n, t, o) {
            var r, c, u, a, f, S, d, s, h, m, v;
            return i = angular.element(i), h = null, m = null, c = null, u = null, s = !0, d = function() {
                var l, e, o, r;
                return u === i ? (l = u.height() + u.scrollTop(), e = t.offset().top + t.height()) : (l = u.height(), e = t.offset().top - u.offset().top + t.height()), o = e - l, r = u.height() * h + 1 >= o, r && m ? n.infiniteScroll() : r ? c = !0 : void 0
            }, v = function(n, i) {
                var e, t, o;
                return o = null, t = 0, e = function() {
                    var i;
                    return t = (new Date).getTime(), l.cancel(o), o = null, n.call(), i = null
                },
                function() {
                    var r, c;
                    return r = (new Date).getTime(), c = i - (r - t), 0 >= c ? (clearTimeout(o), l.cancel(o), o = null, t = r, n.call()) : o ? void 0 : o = l(e, c)
                }
            }, null != e && (d = v(d, e)), n.$on("$destroy", function() {
                return u.off("scroll", d)
            }), S = function(n) {
                return h = parseInt(n, 10) || 0
            }, n.$watch("infiniteScrollDistance", S), S(n.infiniteScrollDistance), f = function(n) {
                return m = !n, m && c ? (c = !1, d()) : void 0
            }, n.$watch("infiniteScrollDisabled", f), f(n.infiniteScrollDisabled), r = function(n) {
                return null != u && u.off("scroll", d), u = n, null != n ? u.on("scroll", d) : void 0
            }, r(i), a = function(n) {
                if (null != n && 0 !== n.length) {
                    if (n = angular.element(n), null != n) return r(n);
                    throw new Exception("invalid infinite-scroll-container attribute.")
                }
            }, n.$watch("infiniteScrollContainer", a), a(n.infiniteScrollContainer || []), null != o.infiniteScrollParent && r(angular.element(t.parent())), null != o.infiniteScrollImmediateCheck && (s = n.$eval(o.infiniteScrollImmediateCheck)), l(function() {
                return s ? d() : void 0
            }, 0)
        }
    }
}]);