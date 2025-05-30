/* eslint-disable no-redeclare */
/* eslint-disable @typescript-eslint/no-unused-vars */
/*
 * Copyright (C) 2012 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * jquery.simulate - simulate browser mouse and keyboard events
 *
 * Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 */

import $ from 'jquery'

function isOpera() {
  const ua = window.navigator.userAgent
  return ua.indexOf('OPR/') !== -1 || ua.indexOf('Opera/') !== -1 || ua.indexOf('OPT/') !== -1
}

$.fn.extend({
  simulate: function (type, options) {
    return this.each(function () {
      var opt = $.extend({}, $.simulate.defaults, options)
      new $.simulate(this, type, opt)
    })
  },
})

$.simulate = function (el, type, options) {
  this.target = el
  this.options = options

  if (type === 'drag') {
    this[type].apply(this, [this.target, options])
  } else if (type === 'focus' || type === 'blur') {
    this[type]()
  } else {
    this.simulateEvent(el, type, options)
  }
}

$.extend($.simulate.prototype, {
  simulateEvent: function (el, type, options) {
    var evt = this.createEvent(type, options)
    this.dispatchEvent(el, type, evt, options)
    return evt
  },
  createEvent: function (type, options) {
    if (/^mouse(over|out|down|up|move)|(dbl)?click$/.test(type)) {
      return this.mouseEvent(type, options)
    } else if (/^key(up|down|press)$/.test(type)) {
      return this.keyboardEvent(type, options)
    }
  },
  mouseEvent: function (type, options) {
    var evt
    var e = $.extend(
      {
        bubbles: true,
        cancelable: type !== 'mousemove',
        view: window,
        detail: 0,
        screenX: 0,
        screenY: 0,
        clientX: 0,
        clientY: 0,
        ctrlKey: false,
        altKey: false,
        shiftKey: false,
        metaKey: false,
        button: 0,
        relatedTarget: undefined,
      },
      options,
    )

    var relatedTarget = $(e.relatedTarget)[0]

    if ($.isFunction(document.createEvent)) {
      evt = document.createEvent('MouseEvents')
      evt.initMouseEvent(
        type,
        e.bubbles,
        e.cancelable,
        e.view,
        e.detail,
        e.screenX,
        e.screenY,
        e.clientX,
        e.clientY,
        e.ctrlKey,
        e.altKey,
        e.shiftKey,
        e.metaKey,
        e.button,
        e.relatedTarget || document.body.parentNode,
      )
    } else if (document.createEventObject) {
      evt = document.createEventObject()
      $.extend(evt, e)
      evt.button = {0: 1, 1: 4, 2: 2}[evt.button] || evt.button
    }
    return evt
  },
  keyboardEvent: function (type, options) {
    var evt

    var e = $.extend(
      {
        bubbles: true,
        cancelable: true,
        view: window,
        ctrlKey: false,
        altKey: false,
        shiftKey: false,
        metaKey: false,
        keyCode: 0,
        charCode: undefined,
      },
      options,
    )

    if ($.isFunction(document.createEvent)) {
      try {
        evt = document.createEvent('KeyEvents')
        evt.initKeyEvent(
          type,
          e.bubbles,
          e.cancelable,
          e.view,
          e.ctrlKey,
          e.altKey,
          e.shiftKey,
          e.metaKey,
          e.keyCode,
          e.charCode,
        )
      } catch (err) {
        evt = document.createEvent('Events')
        evt.initEvent(type, e.bubbles, e.cancelable)
        $.extend(evt, {
          view: e.view,
          ctrlKey: e.ctrlKey,
          altKey: e.altKey,
          shiftKey: e.shiftKey,
          metaKey: e.metaKey,
          keyCode: e.keyCode,
          charCode: e.charCode,
        })
      }
    } else if (document.createEventObject) {
      evt = document.createEventObject()
      $.extend(evt, e)
    }
    if (isOpera()) {
      evt.keyCode = e.charCode > 0 ? e.charCode : e.keyCode
      evt.charCode = undefined
    }
    return evt
  },

  dispatchEvent: function (el, type, evt) {
    if (el.dispatchEvent) {
      el.dispatchEvent(evt)
    } else if (el.fireEvent) {
      el.fireEvent('on' + type, evt)
    }
    return evt
  },

  drag: function (el) {
    var self = this,
      center = this.findCenter(this.target),
      options = this.options,
      x = Math.floor(center.x),
      y = Math.floor(center.y),
      dx = options.dx || 0,
      dy = options.dy || 0,
      target = this.target,
      coord = {clientX: x, clientY: y}
    this.simulateEvent(target, 'mousedown', coord)
    coord = {clientX: x + 1, clientY: y + 1}
    this.simulateEvent(document, 'mousemove', coord)
    coord = {clientX: x + dx, clientY: y + dy}
    this.simulateEvent(document, 'mousemove', coord)
    this.simulateEvent(document, 'mousemove', coord)
    this.simulateEvent(target, 'mouseup', coord)
    this.simulateEvent(target, 'click', coord)
  },
  findCenter: function (el) {
    var el = $(this.target),
      o = el.offset(),
      d = $(document)
    return {
      x: o.left + el.outerWidth() / 2 - d.scrollLeft(),
      y: o.top + el.outerHeight() / 2 - d.scrollTop(),
    }
  },

  focus: function () {
    var focusinEvent,
      triggered = false,
      element = $(this.target)

    function trigger() {
      triggered = true
    }

    element.bind('focus', trigger)
    element[0].focus()

    if (!triggered) {
      focusinEvent = $.Event('focusin')
      focusinEvent.preventDefault()
      element.trigger(focusinEvent)
      element.triggerHandler('focus')
    }
    element.unbind('focus', trigger)
  },

  blur: function () {
    var focusoutEvent,
      triggered = false,
      element = $(this.target)

    function trigger() {
      triggered = true
    }

    element.bind('blur', trigger)
    element[0].blur()

    // blur events are async in IE
    setTimeout(function () {
      // IE won't let the blur occur if the window is inactive
      if (element[0].ownerDocument.activeElement === element[0]) {
        element[0].ownerDocument.body.focus()
      }

      // Firefox won't trigger events if the window is inactive
      // IE doesn't trigger events if we had to manually focus the body
      if (!triggered) {
        focusoutEvent = $.Event('focusout')
        focusoutEvent.preventDefault()
        element.trigger(focusoutEvent)
        element.triggerHandler('blur')
      }
      element.unbind('blur', trigger)
    }, 1)
  },
})

$.extend($.simulate, {
  defaults: {
    speed: 'sync',
  },
  VK_TAB: 9,
  VK_ENTER: 13,
  VK_ESC: 27,
  VK_PGUP: 33,
  VK_PGDN: 34,
  VK_END: 35,
  VK_HOME: 36,
  VK_LEFT: 37,
  VK_UP: 38,
  VK_RIGHT: 39,
  VK_DOWN: 40,
})
