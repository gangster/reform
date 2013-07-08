class <%= class_prefix.pluralize %>Controller < ApplicationController
  respond_to :js, :html

  before_action :set_<%= name %>, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]

  # GET /<%= name.pluralize %>
  # GET /<%= name.pluralize %>.json
  def index
    @<%= name.pluralize %> = Services::<%= class_prefix %>Crud.all
  end

  # GET /<%= name.pluralize %>/1
  # GET /<%= name.pluralize %>/1.json
  def show
  end

  # POST /<%= name.pluralize %>
  # POST /<%= name.pluralize %>.json
  def create
    workflow = Workflows::<%= class_prefix %>Workflow.new(@form, params[:<%= name %>])
    workflow.process do |<%= name %>|
      return respond_with <%= name %>
    end
    render :new
  end

  def update
    workflow = Workflows::<%= class_prefix %>Workflow.new(@form, params[:<%= name %>])
    workflow.process do |<%= name %>|
      return respond_with <%= name %>
    end
    render :edit
  end

  # DELETE /<%= name.pluralize %>/1
  # DELETE /<%= name.pluralize %>/1.json
  def destroy
    Services::<%= class_prefix %>Crud.destroy(@<%= name %>)
    respond_to do |format|
      format.html { redirect_to <%= name.pluralize %>_url }
      format.json { head :no_content }
    end
  end

  private

  def create_new_form
    @form = Forms::<%= class_prefix %>Form.new(<%= name %>: <%= class_prefix %>.new)
  end

  def create_edit_form
    @form = Forms::<%= class_prefix %>Form.new(<%= name %>: @<%= name %>)
  end

  def set_<%= name %>
    @<%= name %> ||= Services::<%= class_prefix %>Crud.find params[:id]
  end
end
