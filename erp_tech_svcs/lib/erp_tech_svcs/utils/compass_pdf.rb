module CompassPDF

  class PDFXLate

    # pdf xlator utility
    attr_accessor :pdf_util

    # options to the pdf xlator
    attr_accessor :util_options

    # temp file that contains the html to be xlated
    attr_accessor :html_filename

    # output option
    attr_accessor :pdf_out_option

    # pdf file generated
    attr_accessor :pdf_filename

    # shell command/s to invoke the xlation process and return the results
    attr_accessor :command

    def initialize(options={})
      # lets default to using prince, we're big spenders
      #options = {:pdf_util => "#{PDF_COMMAND}",:util_options => '--input=html --media=screen --baseurl=http://localhost:3000', :pdf_out_option => '-o '}.merge(options)

      # lets use wkhtmltopdf, we're cheap
      #options = {:pdf_util => "#{PDF_COMMAND}",:util_options => '', :pdf_out_option => ""}.merge(options)
      options.each{ |k,v| self.send("#{k}=".to_sym, v)  }
    end

    def command
      # TODO: send this to a background process to do the xlate
      # TODO: add timeout
      # Could bog down the rails process
#      cmd = "#{@pdf_util} #{@util_options} #{self.html_filename} -o #{self.pdf_out} &>/dev/null;"
      cmd = "#{@pdf_util} #{@util_options} #{self.html_filename} #{self.pdf_out_option} #{pdf_filename}"
#      cmd << "cat #{self.pdf_filename}"
    end

    def html_filename=(file_name)
      @fname = file_name
    end

    def html_filename
      @fname ||= "tmp/html_output_#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.html"    
    end

    def pdf_filename
      html_filename.sub(/\.html/, '.pdf') 
    end

    def write_html_response(body)
      File.open("#{html_filename}", "w") { |f| f.puts(body) }
    end

    def get_pdf_generated
      pdf_contents = nil
      File.open("#{pdf_filename}",'rb') do |f|
        pdf_contents = f.read
      end
      pdf_contents
    end

    def invoke
      puts "invoking command #{self.command}"
      `#{self.command}`
      #TODO: cleanup temp files, etc.
    end
  end

end
