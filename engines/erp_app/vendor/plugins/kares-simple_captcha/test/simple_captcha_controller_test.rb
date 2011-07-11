
require File.expand_path('test_helper', File.dirname(__FILE__))

ActiveRecord::Base.establish_connection('test')
ActiveRecord::Base.silence do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :simple_captcha_data do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end

class SomeController < ActionController::Base
  include SimpleCaptcha::ControllerValidation
  
  def index
    if simple_captcha_valid?
      head 200
    else
      head 409
    end
  end

end

#if Rails.version < '3.0.0'
#  ActionController::Routing::Routes.draw do |map|
#    map.connect '/action', :controller => 'some', :action => 'index'
#  end
#else
#  SimpleCaptcha::Application.routes.draw do
#    match "/action", :to => 'some#index'
#  end
#end

class SimpleCaptchaControllerTest < ActionController::TestCase

  tests SomeController

  setup do
    SimpleCaptchaData.delete_all
  end

  test 'controller respond_to? simple_captcha_valid?' do
    assert SomeController.new.respond_to? :simple_captcha_valid?
  end

  test 'action by default returns 409' do
    with_sample_routing do
      get :index
    end
    assert_response 409
  end

  test 'action with invalid captcha returns 409' do
    # during view rendering key is stored in session :
    SimpleCaptchaData.create! :key => '1234567890', :value => 'ZZZZ'
    @request.session[:simple_captcha] = '1234567890'

    with_sample_routing do
      get :index, :captcha => 'YYYY', :simple_captcha_key => '1234567890'
    end
    assert_response 409
  end

  test 'action with valid captcha returns 200' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'UIII'
    @request.session[:simple_captcha] = '1234567890'

    with_sample_routing do
      get :index, :captcha => 'UIII', :simple_captcha_key => '1234567890'
    end
    assert_response 200
  end

  test 'action with invalid captcha does not invalidate session data' do
    # during view rendering key is stored in session :
    SimpleCaptchaData.create! :key => '1234567890', :value => 'ZZZZ'
    @request.session[:simple_captcha] = '1234567890'

    with_sample_routing do
      get :index, :captcha => 'YYYY', :simple_captcha_key => '1234567890'
    end
    assert_not_nil @request.session[:simple_captcha]
  end

  test 'action with valid captcha invalidates session data' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'UIII'
    @request.session[:simple_captcha] = '1234567890'

    with_sample_routing do
      get :index, :captcha => 'UIII', :simple_captcha_key => '1234567890'
    end
    assert_nil @request.session[:simple_captcha]
  end

  private

    def with_sample_routing(&block)
      with_routing do |set|
        if Rails.version >= '3.0.0'
          set.draw { match "/action", :to => 'some#index' }
        else
          set.draw do |map|
            map.connect '/action', :controller => 'some', :action => 'index'
          end
        end
        block.call
      end
    end

end