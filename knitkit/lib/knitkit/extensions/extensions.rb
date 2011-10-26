#core ruby extensions
require 'knitkit/extensions/core/array'

#railties
require 'knitkit/extensions/railties/action_view'
require 'knitkit/extensions/railties/theme_support/asset_tag_helper'
require 'knitkit/extensions/railties/theme_support/template'

#active_record extensions
require 'knitkit/extensions/active_record/acts_as_commentable'
require 'knitkit/extensions/active_record/acts_as_publishable'
require 'knitkit/extensions/active_record/sti_instantiation'
require 'knitkit/extensions/active_record/theme_support/has_many_themes'

#active_controller extensions
require 'knitkit/extensions/action_controller/theme_support/acts_as_themed_controller'