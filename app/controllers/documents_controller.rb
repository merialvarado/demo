class DocumentsController < ApplicationController

  def index
    @documents = Document.all
  end
  
  def show
    @document = Document.find(params[:id])
  end
  
  def new
    @document = Document.new
    setup_edit_instance_variables
  end
  
  def sort
    params[:document].each_with_index do |id, index|
      Document.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  def create
    @document = Document.new(params[:document])
    respond_to do |format|
      if @document.save
        if params[:step] == "Previous"
          @document.previous_step!
          format.html { redirect_to(edit_document_path(@document)) }
        elsif params[:step] == "Next"
          @document.next_step!
          format.html { redirect_to(edit_document_path(@document)) }
        elsif params[:step] == "Submit"
          @document.submit!
          format.html { redirect_to(@document) }
        end
      else
        setup_edit_instance_variables
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @document = Document.find(params[:id])
    if !setup_edit_instance_variables
      redirect_to(@document, :notice => 'AP Voucher no longer editable.')
    end
  end
  
  def update
    @document = Document.find(params[:id])

    respond_to do |format|
      if params[:step] == "Previous"
        @document.previous_step!
        format.html { redirect_to(edit_document_path(@document)) }
      elsif @document.update_attributes(params[:document])
        if params[:step] == "Next"
          @document.next_step!
          format.html { redirect_to(edit_document_path(@document)) }
        elsif params[:step] == "Submit"
          @document.submit!
          @document.create_attachment
          format.html { redirect_to(@document, :notice => 'Successfully submitted transaction.') }
        end
      else
        setup_edit_instance_variables
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def setup_edit_instance_variables
    edit_setup_ok = false
    if @document.select_sections?
      @section_types = Section::TYPES
      edit_setup_ok = true
    elsif @document.position_sections?
      @sections = @document.sections
      edit_setup_ok = true
    elsif @document.select_template?
      edit_setup_ok = true
    end
    edit_setup_ok
  end

  def show_attachment
    @document = Document.find(params[:id])
    if params[:inline] == true
      send_file(@document.attachment.path, :type => @document.attachment.content_type, :disposition => 'inline')
    else
      send_file(@document.attachment.path, :type => @document.attachment.content_type, :disposition => 'attachment')
    end
  end
  
end
