# app/controllers/party/emails_controller.rb
module Party
  class EmailsController < ApplicationController
    before_action :set_party
    before_action :set_email, only: %i[edit update destroy primary]
    before_action :load_ref_options, only: %i[new edit create update]

    def new
      @email = @party.emails.new
      render layout: false
    end

    def edit
      render layout: false
    end

    def create
      @email = @party.emails.new(email_params)
      if @email.save
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Email added" }
        end
      else
        render :new, status: :unprocessable_entity, layout: false
      end
    end

    def update
      if @email.update(email_params)
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Email updated" }
        end
      else
        render :edit, status: :unprocessable_entity, layout: false
      end
    end

    def destroy
      @email.destroy
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [replace_list] }
        f.html { redirect_to party_party_path(@party.public_id), notice: "Email deleted" }
      end
    end

    def primary
      ::Party::Email.transaction do
        @party.emails.update_all(is_primary: false)
        @email.update!(is_primary: true)
      end
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [replace_list] }
        f.html { redirect_back fallback_location: party_party_path(@party.public_id) }
      end
    end

    private

    def set_party
      pid = params[:party_party_public_id] ||
            params[:party_party_id] ||
            params[:party_public_id] ||
            params[:public_id] ||
            params[:party_id]
      @party = ::Party::Party.find_by!(public_id: pid)
    end

    def set_email
      @email = @party.emails.find(params[:id])
    end

    def load_ref_options
      @email_types = Ref::EmailType.order(:name) if defined?(Ref::EmailType)
    end

    def email_params
      params.require(:party_email).permit(:email, :email_type_code, :is_primary)
    end

    def replace_list
      @party.reload
      turbo_stream.replace(
        view_context.dom_id(@party, :emails_section),
        partial: "party/emails/list",
        locals: { party: @party }
      )
    end

    def refresh_list_and_close
      [replace_list, turbo_stream.replace("comm_modal_frame", partial: "shared/close_modal")]
    end
  end
end
