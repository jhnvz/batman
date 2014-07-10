(function() {
  Batman.ModelExpectations = {
    expectCreate: function(instance, options) {
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectCreate');
      this.assert(instance.isNew(), "Expected " + instance.constructor.name + " to be new when saving");
      return this.stub(instance, 'save', (function(_this) {
        return function(callback) {
          var _ref;
          _this.completeExpectation('expectCreate');
          return callback(options.error, (_ref = options.response) != null ? _ref : instance);
        };
      })(this));
    },
    expectUpdate: function(instance, options) {
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectUpdate');
      this.assert(!instance.isNew(), "Expected " + instance.constructor.name + " to exist when saving");
      return this.stub(instance, 'save', (function(_this) {
        return function(callback) {
          var _ref;
          _this.completeExpectation('expectUpdate');
          return callback(options.error, (_ref = options.response) != null ? _ref : instance);
        };
      })(this));
    },
    expectDestroy: function(instance, options) {
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectDestroy');
      return this.stub(instance, 'destroy', (function(_this) {
        return function(callback) {
          var _ref;
          _this.completeExpectation('expectDestroy');
          return callback(options.error, (_ref = options.response) != null ? _ref : instance);
        };
      })(this));
    },
    expectLoad: function(klass, options) {
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectLoad');
      return this.stub(klass, 'load', (function(_this) {
        return function(innerParams, callback) {
          var _ref;
          if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
            callback = innerParams;
          }
          if (options.params != null) {
            _this.assertEqual(options.params, innerParams);
          }
          _this.completeExpectation('expectLoad');
          return typeof callback === "function" ? callback(options.error, options.response) : void 0;
        };
      })(this));
    },
    expectFind: function(klass, options) {
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectFind');
      return this.stub(klass, 'find', (function(_this) {
        return function(innerParams, callback) {
          var _ref;
          if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
            callback = innerParams;
          }
          if (options.params != null) {
            _this.assertEqual(options.params, innerParams);
          }
          _this.completeExpectation('expectFind');
          return typeof callback === "function" ? callback(options.error, options.response) : void 0;
        };
      })(this));
    }
  };

}).call(this);
