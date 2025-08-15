// ==UserScript==
// @name        Hide Trending Timeline on X.com
// @namespace   http://kawpuh.com
// @description Hides the "Timeline: Trending now" section on X.com
// @author      kawpuh
// @version     1.0
// @include     https://x.com/*
// @grant       none
// @run-at      document-end
// ==/UserScript==

(function() {
    'use strict';
    function hideTrending(element) {
        if (element && element.getAttribute('aria-label') === 'Timeline: Trending now') {
            element.style.display = 'none';
            console.log('Trending timeline hidden'); // Optional: For debugging
        }
    }

    // Initial check on page load
    const initialTrending = document.querySelector('div[aria-label="Timeline: Trending now"]');
    if (initialTrending) {
        hideTrending(initialTrending);
    }

    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
                mutation.addedNodes.forEach(function(node) {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        // Check if the added node itself is the trending div
                        if (node.matches('div[aria-label="Timeline: Trending now"]')) {
                            hideTrending(node);
                        }
                        // Otherwise, check if it contains the trending div
                        const trendingInside = node.querySelector('div[aria-label="Timeline: Trending now"]');
                        if (trendingInside) {
                            hideTrending(trendingInside);
                        }
                    }
                });
            }
        });
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
})();
