
This code is a fork <http://github.com/eshopworks/simple_captcha>

Website: <http://expressica.com/simple_captcha/>

Copyright (c) 2008 [Sur <http://expressica.com>]

Author: Sur

Original Contributors: <http://vinsol.com/team>, Kei Kusakari, nap

"Update" Contributors: Marek de Heus, [Karol Bucek](https://log.kares.org)


Main Updates
------------

Support for a lighter "backend" such as **mini_magick** seems desired, however
**mini_magick** is not really an option due to it's nature of manipulating
existing images (it's API cannot create an image from scratch).
Besides **RMagick** doesn't play well with ruby platforms such as JRuby.
Luckily, there still is an option called **quick_magick** that works on the
command line similar to **mini_magick** but supports a richer API familiar to
**RMagick** users.

This version of SimpleCaptcha introduces a notion of a configurable backend for
generating captcha images. The default backend behaves, depending on RMagick, as
the original plugin, but one might switch to another (built-in) quick_magick
backend as required (or create it's own backend if in the need).

See SETUP / STEP 4 bellow for how to configure the backend.

Besides the plugin now works under Rails 3.0.0+ as well as Rails 2.2.3+ !


Other Updates
-------------

Merged changes from <http://github.com/mdh/simple_captcha>

This forked version is different in a few ways. I changed it so that the
captcha validation is just that: another validation. This makes it much
easier to use it in combination with things like resource_controller.

The original version does all kinds of method aliasing and requires you
to write code specifically for handling the captcha validation. This version
accepts the usual :if, :unless and :on options.

This version does not bypass the validation if in test mode. It behaves the
same in all environments, allowing you to actually test it.

To disable the validations in test mode, You should now state it explicitly:

    class User < ActiveRecord::Base
      validates_captcha :unless => lambda { Rails.env.test? }
    end

NOTE: This will validate captcha every-time You do a `user.save` !

There's an API that allows You to (temporary) disable captcha validation for
classes, individual instances or even blocks :

    User.captcha_validation = false # disables validation globally
    user = User.new
    ...
    # force captcha validation for the given instance and block
    user.captcha_validation(true) do
      user.save!
    end
    ...
    # enable captcha validation for the given instance
    user.captcha_validation(true)
    user.save
    ...
    # reset captcha validation - fallback to the class setting
    user.captcha_validation(nil)
    user.save # validates captcha if User.captcha_validation?


Old Validation
--------------

A backward compatible validation for Your model classes is as well available.
The original captcha validation code was different from standard validation in
a way that it did not validate the captcha on "regular" `save` calls, one has
to explicitly state captcha validation is desired by calling `save_with_captcha`.

    class User < ActiveRecord::Base
      apply_simple_captcha :message => 'WTF?!'
    end

NOTE: The "old" behavior is emulated using the captcha_validation flags.

SimpleCaptcha
=============
  
SimpleCaptcha is the simplest and a robust captcha plugin. Its implementation
requires adding up a single line in views and in controllers/models.
SimpleCaptcha is available to be used with Rails 2.0 or above and also it
provides the backward compatibility with previous versions of Rails.
  
### Features
  
 - Zero FileSystem usage(secret code moved to db-store and image storage removed).
 - Provides various image styles.
 - Provides three level of complexity of images.
 - Works absolutely fine in distributed environment(session and db based implementation
   works fine in distributed environment).
 - Implementation is as easy as just writing a single line in your view.
   `<%= show_simple_captcha %>` within the 'form' tags.
 - Flexible DOM and CSS handling(There is a separate view partial for rendering 
   SimpleCaptcha DOM elements).
 - Automated removal of 1 hour old unmatched simple_captcha data.

### Pre-Requisite

  [RMagick](http://rmagick.rubyforge.org) or [quick_magick](https://rubyforge.org/projects/quickmagick)
  should be installed on your machine to use this plugin.


### Installation
  
    ruby script/plugin install git://github.com/kares/simple_captcha.git


### Setup

After installation, follow these simple steps to setup the plugin. 
The setup will depend on the version of rails your application is using.

#### STEP 1

 for Rails 2.x :

    script/generate simple_captcha

 for Rails 3.x :

    rails generate simple_captcha

#### STEP 2

    rake db:migrate

#### STEP 3 (required only for Rails < 2.3.0)
  
  add the following code into `config/routes.rb` :
    
    ActionController::Routing::Routes.draw do |map|
      map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
    end
  
This is a mandatory route used for rendering the simple_captcha image on the fly
without storing on the filesystem.

#### STEP 4 (Optional)

  configure simple_captcha e.g. in `app/config/initializers/simple_captcha.rb`

    SimpleCaptcha.backend = :quick_magick # default is :RMagick

    SimpleCaptcha.image_options = {
        :image_color => 'white',
        :image_size => '110x30',
        :text_color => 'black',
        :text_font => 'arial',
        :text_size => 22
    } # these are the defaults

  Please note that some image options such as color might change when using
  some of the pre-built captcha image styles available.


### Usage

#### Controller Based

  Include `SimpleCaptcha::ControllerValidation` into Your captcha validating
  controller or put the include into `app/controllers/application.rb`

    ApplicationController < ActionController::Base
      include SimpleCaptcha::ControllerValidation
    end

  in the view file within the form tags add this code
    
    <%= show_simple_captcha %>
    
  and in the controller's action authenticate it as 
    
    if simple_captcha_valid?
      do this
    else
      do that
    end


#### Model Based
  
  In the view file within the form tags write this code

    <%= show_simple_captcha(:object=>"user") %>

  and in the model class include `SimpleCaptcha::ModelValidation` and setup
  the validation

    class User < ActiveRecord::Base
      include SimpleCaptcha::ModelValidation

      validates_captcha :on => :create, :message => 'invalid captcha'
    end

  or if You prefer the old version which doesn't trigger the captcha
  validation on `save` (one have to call `save_with_captcha`)

    class User < ActiveRecord::Base
      include SimpleCaptcha::ModelValidation
      
      apply_simple_captcha :message => :'invalid_captcha'
    end


Options & Examples
------------------

    View Options
    ==========================================================================

    :label
    --------------------------------------------------------------------------
      provides the custom text b/w the image and the text field,
      the default is "type the code from the image"

    :image_style
    --------------------------------------------------------------------------
      Provides the specific image style for the captcha image.
      There are eight different styles available with the plugin as...
      1) simply_blue
      2) simply_red
      3) simply_green
      4) charcoal_grey
      5) embosed_silver
      6) all_black
      7) distorted_black
      8) almost_invisible

      See the included samples <http://github.com/kares/simple_captcha/samples>.
      You can also specify 'random' to select the random image style.


    :distortion
    --------------------------------------------------------------------------
      Handles the complexity of the image. The :distortion can be set to 'low',
      'medium' or 'high'. Default is 'low'.

    :object
    --------------------------------------------------------------------------
      the name of the object of the model class, to implement the model based
      captcha.


    How to change the CSS for SimpleCaptcha DOM elements ?
    -----------------------------------------------------
    You can change the CSS of the SimpleCaptcha DOM elements as per your need
    in this file.
    For Rails >= 2.0 the file wiil reside as...
    "/app/views/simple_captcha/_simple_captcha.erb"
    For Rails < 2.0 the file will reside as...
    "/app/views/simple_captcha/_simple_captcha.rhtml"


    View's Examples
    ==========================================================================

    Controller Based Example
    --------------------------------------------------------------------------
      example
      -------
      <%= show_simple_captcha(:label => "human authentication") %>

      example
      -------
      <%= show_simple_captcha(:label       => "human authentication",
                              :image_style => 'embosed_silver') %>

      example
      -------
      <%= show_simple_captcha(:label       => "human authentication",
                              :image_style => 'simply_red',
                              :distortion  => 'medium') %>

    Model Based Example
    --------------------------------------------------------------------------

      example
      -------
      <%= show_simple_captcha(:object => 'user',
                              :label  => "human authentication") %>



    Model Options
    ==========================================================================

    :message
    --------------------------------------------------------------------------
      provides the custom message on failure of captcha authentication
      the default is "Secret Code did not match with the Image"

    :add_to_base
    --------------------------------------------------------------------------
      if set to true, appends the error message to the base.

    Model's Example
    ==========================================================================

      example
      -------
      class User < ActiveRecord::Base
        apply_simple_captcha # the "old" way using save_with_captcha
      end

      example
      -------
      class User < ActiveRecord::Base
        validates_captcha :message => "Are you a bot?", :add_to_base => true
      end

    ==========================================================================
