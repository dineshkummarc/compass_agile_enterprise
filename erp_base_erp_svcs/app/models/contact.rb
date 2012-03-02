class Contact < ActiveRecord::Base
    has_and_belongs_to_many :contact_purposes
    belongs_to :party
    belongs_to :contact_mechanism, :polymorphic => true
  
    #rather than carry our own description for the abstract -contact-, we'll
    #delegate that call to the implementor of the -contact_mechanism- interface

    def description
        @description = contact_mechanism.description
    end

    def description=(d)
        @description=d
    end

    #delegate our need to provide a label to scaffolds to the implementor of
    #the -contact_mechanism- interface.

    def to_label
        "#{contact_mechanism.description}"
    end

    def summary_line
        "#{contact_mechanism.summary_line}"
    end

    # return first contact purpose
    def purpose
        contact_purposes.first.description
    end

    # return all contact purposes as an array
    def purposes
    	p = []
      contact_purposes.each do |cp|
      	p << cp.description
      end

      return p
    end
end
