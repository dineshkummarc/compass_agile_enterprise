module ErpApp
	module Shared
		class Shared::NotesController < ErpApp::ApplicationController

		  def view
        if params[:party_id].to_i == 0
          render :json => {:totalCount => 0, :notes => []}
        else
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          limit = params[:limit] || 30
          start = params[:start] || 0

          sort = sort_hash[:property] || 'created_at'
          dir  = sort_hash[:direction] || 'DESC'

          Note.include_root_in_json = false
			
          party = Party.find(params[:party_id])
          notes = party.notes.order("#{sort} #{dir}").limit(limit).offset(start)
			
          render :inline => "{\"totalCount\":#{party.notes.count}, \"notes\":#{notes.to_json(:only => [:id, :content, :created_at], :methods => [:summary, :note_type_desc, :created_by_username])}}"
        end
		  end

		  def create
        content  = params[:content]
        note_type = NoteType.find(params[:note_type_id])
        party = Party.find(params[:party_id])

        note = Note.create(
          :note_type => note_type,
          :content => content,
          :created_by_id => current_user.party.id
        )

        party.notes << note
        party.save

        render :json => {:success => true}
		  end

		  def delete
        Note.find(params[:id]).destroy ? (render :json => {:success => true}) : (render :json => {:success => false})
		  end

		  def note_types
        NoteType.include_root_in_json = false

        render :json => {:note_types => NoteType.all}
		  end
		end
	end
end
