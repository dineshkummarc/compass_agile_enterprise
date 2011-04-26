
require File.expand_path('test_helper', File.dirname(__FILE__))

ActiveRecord::Base.establish_connection('test')
ActiveRecord::Base.silence do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.string  :type
      t.string  :name
    end
    create_table :simple_captcha_data do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end

class SimpleCaptchaModelTest < ActiveSupport::TestCase

  CAPTCHA_DISABLED = false

  class UserWithCaptcha < ActiveRecord::Base
    include SimpleCaptcha::ModelValidation
    
    set_table_name 'users'

    validates_presence_of :name

    validates_captcha :unless => lambda { SimpleCaptchaModelTest::CAPTCHA_DISABLED }
  end

  class InheritedUser < UserWithCaptcha
  end

  setup do
    SimpleCaptchaData.delete_all
  end

  test 'captcha validations run by default' do
    user = UserWithCaptcha.new :name => 'ferko'
    assert ! user.valid?
  end

  test 'captcha validations run on create' do
    user = UserWithCaptcha.new :name => 'ferko'
    assert ! user.save
    assert user.errors.on(:captcha)
  end

  test 'captcha validations run on update' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'HUU'
    UserWithCaptcha.create! :name => 'jozko', :captcha => 'HUU', :captcha_key => '1234567890'
    assert_not_nil user = UserWithCaptcha.find_by_name('jozko')
    assert ! user.save
    assert user.errors.on(:captcha)
  end

  test 'captcha validations is skipped when condition is met' do
    user = UserWithCaptcha.new :name => 'jozko'
    assert ! user.valid?
    begin
      silence_warnings { SimpleCaptchaModelTest.const_set(:CAPTCHA_DISABLED, true) }
      assert user.valid?
      assert UserWithCaptcha.new(:name => 'ferko').valid?
    ensure
      silence_warnings { SimpleCaptchaModelTest.const_set(:CAPTCHA_DISABLED, false) }
    end

    user = UserWithCaptcha.new :name => ''
    assert ! user.valid?
    begin
      silence_warnings { SimpleCaptchaModelTest.const_set(:CAPTCHA_DISABLED, true) }
      assert ! user.valid?
      assert user.errors.on(:name)
      assert ! UserWithCaptcha.new.valid?
    ensure
      silence_warnings { SimpleCaptchaModelTest.const_set(:CAPTCHA_DISABLED, false) }
    end
  end

  test 'captcha validation outcome is kept on multiple calls 1' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'HUU'

    user = UserWithCaptcha.new :name => 'hey', :captcha => 'EEE', :captcha_key => '1234567890'

    assert ! user.valid?
    user.name = 'U2'
    assert ! user.valid?
    assert ! user.valid?
    assert ! user.save
    assert ! user.valid?
  end

  test 'captcha validation outcome is kept on multiple calls 2' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'HELLO'

    user = UserWithCaptcha.new :name => 'hey', :captcha => 'HELLO', :captcha_key => '1234567890'
    assert user.valid?
    user.name = 'U2'
    assert user.valid?
    assert user.valid?
    assert user.save
    assert user.valid?
  end

  test 'captcha validations might be disabled for class' do
    user = UserWithCaptcha.new :name => 'cicinbrus'
    begin
      UserWithCaptcha.captcha_validation = false
      assert user.valid?
      assert UserWithCaptcha.new(:name => 'cicinbrus').valid?
    ensure
      UserWithCaptcha.captcha_validation = true
    end
  end

  test 'captcha validations might be disabled for block' do
    user = UserWithCaptcha.new :name => 'cicinbrus'
    user.captcha_validation(false) do
      assert user.valid?
      assert ! UserWithCaptcha.new(:name => 'cicinbrus').valid?
    end
  end

  test 'disabling validations is not class inherited' do
    begin
      UserWithCaptcha.captcha_validation = false
      assert UserWithCaptcha.new(:name => 'cicina').valid?
      assert ! InheritedUser.new(:name => 'cicina').valid?
    ensure
      UserWithCaptcha.captcha_validation = true
    end
  end

  test 'disabled captcha validations get enabled for block' do
    user = UserWithCaptcha.new :name => 'pejko'
    begin
      assert ! user.valid?
      UserWithCaptcha.captcha_validation = false
      assert user.valid?
      user.captcha_validation(true) do
        assert ! user.valid?
        assert UserWithCaptcha.new(:name => 'hujko').valid?
      end
      assert user.valid?
      assert UserWithCaptcha.new(:name => 'tutko').valid?
    ensure
      UserWithCaptcha.captcha_validation = true
    end
  end

  class UserWithCaptchaOnCreate < ActiveRecord::Base
    include SimpleCaptcha::ModelValidation

    set_table_name 'users'

    validates_captcha :on => :create
  end

  test 'user with captcha on create is not saved without captcha' do
    user = UserWithCaptchaOnCreate.new :name => 'cicinbrus'
    assert ! user.save
  end

  test 'user with captcha on create is saved with valid captcha' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'HELLO'

    user = UserWithCaptchaOnCreate.new :name => 'cicinbrus', :captcha => 'HELLO', :captcha_key => '1234567890'
    assert user.save
  end

  test 'user with captcha on create is updated without captcha being validated' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'HELLO'

    user = UserWithCaptchaOnCreate.create! :name => 'melisko', :captcha => 'HELLO', :captcha_key => '1234567890'
    assert_not_nil user = UserWithCaptchaOnCreate.find_by_name('melisko')
    user.captcha = 'XXX'
    user.name = 'jepemboha'
    assert user.save
    #puts user.errors.inspect
    assert_nil UserWithCaptchaOnCreate.find_by_name('melisko')
  end

  class UserWithCaptchaBackwardCompatible < ActiveRecord::Base
    include SimpleCaptcha::ModelValidation
    set_table_name 'users'

    apply_simple_captcha :message => 'invalid captcha !'
  end

  test 'backward compatible - captcha is not validated by default' do
    user = UserWithCaptchaBackwardCompatible.new
    assert user.valid?
    assert user.save!
  end

  test 'backward compatible - responds_to save_with_captcha' do
    user = UserWithCaptchaBackwardCompatible.new
    assert user.respond_to? :save_with_captcha
  end

  test 'backward compatible - captcha is validated with save_with_captcha 1' do
    user = UserWithCaptchaBackwardCompatible.new :name => 'xxx',
             :captcha => 'ABCDEF', :captcha_key => '1234567890'
    assert ! user.save_with_captcha
  end

  test 'backward compatible - captcha is validated with save_with_captcha 2' do
    SimpleCaptchaData.create! :key => '1234567890', :value => 'ABCDEF'

    user = UserWithCaptchaBackwardCompatible.new :name => 'xxx',
             :captcha => 'ABCDEF', :captcha_key => '1234567890'
    assert user.save_with_captcha
  end

  test 'backward compatible - validated captcha error message' do
    user = UserWithCaptchaBackwardCompatible.new :name => 'xxx',
             :captcha => 'QWERTY', :captcha_key => '1234567890'
    assert ! user.save_with_captcha
    assert ! user.errors.blank?
    assert user.errors.on(:captcha)
    assert_equal 'invalid captcha !', user.errors.on(:captcha)
  end

end