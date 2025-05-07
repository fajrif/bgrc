(function () {
	("use strict");

	/**
	 *  global variables
	 */
	var navbarMenuHTML = document.querySelector(".navbar-menu").innerHTML;

	// on click collapse menu
	function isCollapseMenu() {
		/**
		 * Sidebar menu collapse
		 */
		if (document.querySelectorAll(".navbar-nav .collapse")) {
			var collapses = document.querySelectorAll(".navbar-nav .collapse");
			Array.from(collapses).forEach(function (collapse) {
				// Init collapses
				var collapseInstance = new bootstrap.Collapse(collapse, {
					toggle: false,
				});
				// Hide sibling collapses on `show.bs.collapse`
				collapse.addEventListener("show.bs.collapse", function (e) {
					e.stopPropagation();
					var closestCollapse = collapse.parentElement.closest(".collapse");
					if (closestCollapse) {
						var siblingCollapses = closestCollapse.querySelectorAll(".collapse");
						Array.from(siblingCollapses).forEach(function (siblingCollapse) {
							var siblingCollapseInstance = bootstrap.Collapse.getInstance(siblingCollapse);
							if (siblingCollapseInstance === collapseInstance) {
								return;
							}
							siblingCollapseInstance.hide();
						});
					} else {
						var getSiblings = function (elem) {
							// Setup siblings array and get the first sibling
							var siblings = [];
							var sibling = elem.parentNode.firstChild;
							// Loop through each sibling and push to the array
							while (sibling) {
								if (sibling.nodeType === 1 && sibling !== elem) {
									siblings.push(sibling);
								}
								sibling = sibling.nextSibling;
							}
							return siblings;
						};
						var siblings = getSiblings(collapse.parentElement);
						Array.from(siblings).forEach(function (item) {
							if (item.childNodes.length > 2)
								item.firstElementChild.setAttribute("aria-expanded", "false");
							var ids = item.querySelectorAll("*[id]");
							Array.from(ids).forEach(function (item1) {
								item1.classList.remove("show");
								if (item1.childNodes.length > 2) {
									var val = item1.querySelectorAll("ul li a");
									Array.from(val).forEach(function (subitem) {
										if (subitem.hasAttribute("aria-expanded"))
											subitem.setAttribute("aria-expanded", "false");
									});
								}
							});
						});
					}
				});

				// Hide nested collapses on `hide.bs.collapse`
				collapse.addEventListener("hide.bs.collapse", function (e) {
					e.stopPropagation();
					var childCollapses = collapse.querySelectorAll(".collapse");
					Array.from(childCollapses).forEach(function (childCollapse) {
						childCollapseInstance = bootstrap.Collapse.getInstance(childCollapse);
						childCollapseInstance.hide();
					});
				});
			});
		}
	}

	// Toggle Hamburger Menu
	function toggleHamburgerMenu() {
		var windowSize = document.documentElement.clientWidth;

		if (windowSize > 767)
			document.querySelector(".hamburger-icon").classList.toggle("open");

		//For collapse vertical menu
		if (document.documentElement.getAttribute("data-layout") === "vertical") {
			if (windowSize <= 1025 && windowSize > 767) {
				document.body.classList.remove("vertical-sidebar-enable");
				document.documentElement.getAttribute("data-sidebar-size") == "sm" ?
					document.documentElement.setAttribute("data-sidebar-size", "") :
					document.documentElement.setAttribute("data-sidebar-size", "sm");
			} else if (windowSize > 1025) {
				document.body.classList.remove("vertical-sidebar-enable");
				document.documentElement.getAttribute("data-sidebar-size") == "lg" ?
					document.documentElement.setAttribute("data-sidebar-size", "sm") :
					document.documentElement.setAttribute("data-sidebar-size", "lg");
			} else if (windowSize <= 767) {
				document.body.classList.add("vertical-sidebar-enable");
				document.documentElement.setAttribute("data-sidebar-size", "lg");
			}
		}
	}

	function initComponents() {
		// tooltip
		var tooltipTriggerList = [].slice.call(
			document.querySelectorAll('[data-bs-toggle="tooltip"]')
		);
		tooltipTriggerList.map(function (tooltipTriggerEl) {
			return new bootstrap.Tooltip(tooltipTriggerEl);
		});

		// popover
		var popoverTriggerList = [].slice.call(
			document.querySelectorAll('[data-bs-toggle="popover"]')
		);
		popoverTriggerList.map(function (popoverTriggerEl) {
			return new bootstrap.Popover(popoverTriggerEl);
		});
	}

	function initMenuItemScroll() {
		setTimeout(function () {
			var sidebarMenu = document.getElementById("navbar-nav");
			if (sidebarMenu) {
				var activeMenu = sidebarMenu.querySelector(".nav-item .active");
				var offset = activeMenu ? activeMenu.offsetTop : 0;
				if (offset > 300) {
					var verticalMenu = document.getElementsByClassName("app-menu") ? document.getElementsByClassName("app-menu")[0] : "";
					if (verticalMenu && verticalMenu.querySelector(".simplebar-content-wrapper")) {
						setTimeout(function () {
							offset == 330 ?
								(verticalMenu.querySelector(".simplebar-content-wrapper").scrollTop = offset + 85) :
								(verticalMenu.querySelector(".simplebar-content-wrapper").scrollTop = offset);
						}, 0);
					}
				}
			}
		}, 250);
	}

	function initLeftMenuCollapse() {
		/**
		 * Vertical layout menu scroll add
		 */
		if (document.documentElement.getAttribute("data-layout") == "vertical" || document.documentElement.getAttribute("data-layout") == "semibox") {
			document.getElementById("two-column-menu").innerHTML = "";
			if (document.querySelector(".navbar-menu")) {
				document.querySelector(".navbar-menu").innerHTML = navbarMenuHTML;
			}
			document.getElementById("scrollbar").setAttribute("data-simplebar", "");
			document.getElementById("navbar-nav").setAttribute("data-simplebar", "");
			document.getElementById("scrollbar").classList.add("h-100");
		}

		/**
		 * Two-column layout menu scroll add
		 */
		if (document.documentElement.getAttribute("data-layout") == "twocolumn") {
			document.getElementById("scrollbar").removeAttribute("data-simplebar");
			document.getElementById("scrollbar").classList.remove("h-100");
		}
	}

	function init() {
		initLeftMenuCollapse();
		initComponents();
		isCollapseMenu();
		if (document.getElementById("topnav-hamburger-icon")) {
			document.getElementById("topnav-hamburger-icon").addEventListener("click", toggleHamburgerMenu);
		}
		initMenuItemScroll();
	}
	init();

	var timeOutFunctionId;

	function setResize() {
		var currentLayout = document.documentElement.getAttribute("data-layout");
		if (currentLayout !== "horizontal") {
			if (document.getElementById("navbar-nav")) {
				var simpleBar = new SimpleBar(document.getElementById("navbar-nav"));
				if (simpleBar) simpleBar.getContentElement();
			}

			if (document.getElementsByClassName("twocolumn-iconview")[0]) {
				var simpleBar1 = new SimpleBar(
					document.getElementsByClassName("twocolumn-iconview")[0]
				);
				if (simpleBar1) simpleBar1.getContentElement();
			}
			clearTimeout(timeOutFunctionId);
		}
	}

	window.addEventListener("resize", function () {
		if (timeOutFunctionId) clearTimeout(timeOutFunctionId);
		timeOutFunctionId = setTimeout(setResize, 2000);
	});

})();
