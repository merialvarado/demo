class Document < ActiveRecord::Base
  attr_accessible :name, :sections_attributes, :state, :attachment, :attachment_file_name, :attachment_content_type, :attachment_file_size, :attachment_updated_at
  
  has_many :sections
  accepts_nested_attributes_for :sections
  has_attached_file :attachment,
    :url => "/:class/:id/original/:basename.:extension",
    :path => ":rails_root/uploads/:class/:id/original/:basename.:extension"
  
  include Workflow

  workflow_column :state

  workflow do
    state :select_sections do
      event :next_step, :transitions_to => :position_sections
    end
    state :position_sections do
      event :previous_step, :transitions_to => :select_sections
      event :next_step, :transitions_to => :select_template
    end
    state :select_template do
      event :previous_step, :transitions_to => :position_sections
      event :submit, :transitions_to => :completed
    end
    state :completed
  end

  include Workflow::Helper
  workflow_add_can_helpers
  
  
  def create_attachment
    file = StringIO.new(self.create_pdf_file) #mimic a real upload file
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = 'sample_document'
    file.content_type = "application/pdf"

    self.attachment = file
    self.save
  end
  
  # Create a pdf file of a job's details.
  # @param [Object] job the job wherein the details of the pdf file will be retrieved from
  # @return [PDF format file] the pdf format file which contains the details of the job
  def create_pdf_file
    pdf = Prawn::Document.new(:page_size => "LETTER", :margin => 50)
    font_dir = "#{Rails.root.to_s}/public/fonts"
    pdf.font_families.update( "olb_font" =>
                           { :normal => "#{font_dir}/Trebuchet_MS.ttf",
                             :bold => "#{font_dir}/Trebuchet_MS_Bold.ttf",
                             :normal_title => "#{font_dir}/arialbd.ttf",
                             :bold_italic => "#{font_dir}/Trebuchet_MS_Bold_Italic.ttf"
                           })
    
    pdf.font "olb_font"
    pdf.font_size(9)
    
    #Styling
    eval(get_pdf_markup(self))
    
    return pdf.render
  end
  
  # Layout the job's details into the pdf document.
  # @param [Object] job the job where the details to be layout should be retrieved from
  # @return []
  def get_pdf_markup(document)
    return <<-EOS
      address = self.sections.where(:section_type => 'Address').first
      sections = self.sections.where(:section_type => 'Section').order('position asc')
      
      pdf.define_grid(:columns => 5, :rows => sections.size, :gutter => 10)
      
      pdf.text_box address.body, :at => [0, pdf.cursor], :overflow => :shrink_to_fit, :width => 200, :height => 50
      
      
      counter = 0
      sections.each do |section|
        counter += 1
        pdf.grid([counter,1], [counter, 3]).bounding_box do
          pdf.text section.body unless section.blank?
        end
      end
    EOS
  end
end