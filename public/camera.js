(function() {
  var Controls;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  };
  Controls = function(object, domElement) {
    this.object = object;
    this.target = new THREE.Vector3(0, 0, 0);
    this.domElement = domElement || document;
    this.lookSpeed = 0.20;
    this.mouseX = 0;
    this.mouseY = 0;
    this.lat = 0;
    this.lon = 220;
    this.phi = 0;
    this.theta = 0;
    this.mouseDragOn = false;
    this.anchorx = null;
    this.anchory = null;
    this.defineBindings();
    return this;
  };
  Controls.prototype.defineBindings = function() {
    $(this.domElement).mousemove(__bind(function(e) {
      return this.onMouseMove(e);
    }, this));
    $(this.domElement).mousedown(__bind(function(e) {
      return this.onMouseDown(e);
    }, this));
    $(this.domElement).mouseup(__bind(function(e) {
      return this.onMouseUp(e);
    }, this));
    $(this.domElement).bind("contextmenu", function() {
      return false;
    });
    return $(this.domElement).mouseenter(__bind(function(e) {
      return this.onMouserEnter(e);
    }, this));
  };
  Controls.prototype.onMouserEnter = function(event) {
    var isLeftButtonDown;
    isLeftButtonDown = event.button === 0 && event.which === 1;
    if (!(isLeftButtonDown)) {
      return this.onMouseUp(event);
    }
  };
  Controls.prototype.onMouseDown = function(event) {
    if (this.domElement !== document) {
      this.domElement.focus();
    }
    this.anchorx = event.pageX;
    this.anchory = event.pageY;
    this.setMouse(event);
    this.mouseDragOn = true;
    return false;
  };
  Controls.prototype.onMouseUp = function(event) {
    this.mouseDragOn = false;
    return false;
  };
  Controls.prototype.setMouse = function(event) {
    this.mouseX = event.pageX;
    return (this.mouseY = event.pageY);
  };
  Controls.prototype.onMouseMove = function(event) {
    if (!(this.mouseDragOn)) {
      return null;
    }
    this.setMouse(event);
    return null;
  };
  Controls.prototype.halfCircle = Math.PI / 180;
  Controls.prototype.viewDirection = function() {
    return this.target.clone().subSelf(this.object.position);
  };
  Controls.prototype.move = function(newPosition) {
    var _ref, cos, max, min, p, sin;
    _ref = Math;
    sin = _ref.sin;
    cos = _ref.cos;
    max = _ref.max;
    min = _ref.min;
    this.object.position = newPosition;
    p = this.object.position;
    assoc(this.target, {
      x: p.x + 100 * sin(this.phi) * cos(this.theta),
      y: p.y + 100 * cos(this.phi),
      z: p.z + 100 * sin(this.phi) * sin(this.theta)
    });
    return null;
  };
  Controls.prototype.update = function() {
    var _ref, cos, max, min, p, sin;
    if (!(this.mouseDragOn)) {
      return null;
    }
    if (this.mouseX === this.anchorx && this.mouseY === this.anchory) {
      return null;
    }
    _ref = Math;
    sin = _ref.sin;
    cos = _ref.cos;
    max = _ref.max;
    min = _ref.min;
    this.lon += (this.mouseX - this.anchorx) * this.lookSpeed;
    this.lat -= (this.mouseY - this.anchory) * this.lookSpeed;
    this.anchorx = this.mouseX;
    this.anchory = this.mouseY;
    this.lat = max(-85, min(85, this.lat));
    this.phi = (90 - this.lat) * this.halfCircle;
    this.theta = this.lon * this.halfCircle;
    p = this.object.position;
    assoc(this.target, {
      x: p.x + 100 * sin(this.phi) * cos(this.theta),
      y: p.y + 100 * cos(this.phi),
      z: p.z + 100 * sin(this.phi) * sin(this.theta)
    });
    this.object.lookAt(this.target);
    return null;
  };
window.Controls = Controls
}).call(this);
