class DocumentMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def email_document(to_email, document)
    file = document.files.first
    attachments[file.data_file_name] = document.files.first.get_contents

    mail(:to => to_email, :subject => 'The Document You Requested')
  end
end
