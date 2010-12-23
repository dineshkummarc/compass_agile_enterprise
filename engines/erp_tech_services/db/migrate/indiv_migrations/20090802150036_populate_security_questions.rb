# Company approved security questions
class PopulateSecurityQuestions < ActiveRecord::Migration
    def self.up
        SecurityQuestion.create(:question => 'What was the name of your elementary/primary school?')

        SecurityQuestion.create(:question => 'What is the middle name of your youngest child?')

        SecurityQuestion.create(:question => 'What street did you live on in third grade?')

        SecurityQuestion.create(:question => 'What is your mother\'s maiden name?')

        SecurityQuestion.create(:question => 'What was your childhood nickname?')

        SecurityQuestion.create(:question => 'What is the name of your favorite pet?')

        SecurityQuestion.create(:question => 'In what city were you born?')

        SecurityQuestion.create(:question => 'What is the name of your college (or high school)?')

        SecurityQuestion.create(:question => 'What was your high school (or college) mascot?')

        SecurityQuestion.create(:question => 'Where is your Home Resort?')

        SecurityQuestion.create(:question => 'Where is your favorite Holiday Inn Club destination?')

        SecurityQuestion.create(:question => 'What is your member level?')
    end

    def self.down
        # drop_table :security_questions
    end
end
