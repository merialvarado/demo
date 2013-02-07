class SectionsController < ApplicationController

  def index
    @sections = Section.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sections }
    end
  end
  
  def show
    @section = Section.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @section }
    end
  end
  
  def new
    @section = Section.new
    @section_types = Section::TYPES
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @section }
    end
  end
  
  def create
    @section = Section.new(params[:section])
    
    respond_to do |format|
      if @section.save
        flash[:success] = 'section was successfully created.'
        format.html { redirect_to @section }
        format.json { render json: @section, status: :created, location: @section }
      else
        @section_types = Section::TYPES
        format.html { render action: "new" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit
    @section = Section.find(params[:id])
    @section_types = Section::TYPES
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @section }
    end
  end
  
  def update
    @section = Section.find(params[:id])
    
    respond_to do |format|
      if @section.update_attributes(params[:section])
        flash[:success] = 'section was successfully updated.'
        format.html { redirect_to @section }
        format.json { render json: @section, status: :created, location: @section }
      else
        @section_types = Section::TYPES
        format.html { render action: "edit" }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def sort
    params[:section].each_with_index do |id, index|
      Section.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
