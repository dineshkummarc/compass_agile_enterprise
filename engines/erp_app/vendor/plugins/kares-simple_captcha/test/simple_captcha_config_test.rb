
require File.expand_path('test_helper', File.dirname(__FILE__))

class SimpleCaptchaConfigTest < ActiveSupport::TestCase

  setup do
    SimpleCaptcha.backend = nil
  end

  test 'backend configuration defaults to RMagick' do
    assert_not_nil SimpleCaptcha.backend
    assert_equal 'SimpleCaptcha::RMagickBackend', SimpleCaptcha.backend.to_s
  end

  test 'set backend configuration to quick_magick' do
    SimpleCaptcha.backend = :quick_magick
    
    assert_not_nil SimpleCaptcha.backend
    assert_equal 'SimpleCaptcha::QuickMagickBackend', SimpleCaptcha.backend.to_s
  end

  test 'set backend configuration to RMagick' do
    SimpleCaptcha.backend = :RMagick

    assert_not_nil SimpleCaptcha.backend
    assert_equal 'SimpleCaptcha::RMagickBackend', SimpleCaptcha.backend.to_s
  end

  test 'set backend configuration to rmagick' do
    SimpleCaptcha.backend = :rmagick

    assert_not_nil SimpleCaptcha.backend
    assert_equal 'SimpleCaptcha::RMagickBackend', SimpleCaptcha.backend.to_s
  end

end