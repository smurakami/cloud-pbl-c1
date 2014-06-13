class ImageProcessingController < ApplicationController

  ## Front page
  def default
    render "image_processing/default"
  end

  ##
  ## Adaptive filtering
  ##
  def adaptive
    ## Receive the posted data
    temp = Tempfile::open(['adaptive-in', '.jpg'], :encoding => 'ascii-8bit')
    while blk = request.body.read(4096)
      temp.write(blk)
    end
    img = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    temp.close

    ## Apply the adaptive thresholding algorithm
    res = img.adaptive_threshold(255, :adaptive_method => :gaussian_c, :threshold_type => :binary, :block_size => 7, :param1 => 4)

    ## Create a temporary file and save the output image there
    temp = Tempfile::open(['adaptive-out', '.jpg'], :encoding => 'ascii-8bit')
    res.save(temp.path)
    ## Render the saved image
    send_file temp.path, :type => 'image/jpeg', :disposition => 'inline'
    ## Close and delete the temporary file
    temp.close
  end

  ##
  ## Face recognition
  ##
  def facerecog
    ## Receive the posted data
    temp = Tempfile::open(['adaptive-in', '.jpg'], :encoding => 'ascii-8bit')
    while blk = request.body.read(4096)
      temp.write(blk)
    end
    img = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)
    temp.close

    ## Apply the face  recognition
    detector = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    detector.detect_objects(img, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
      img.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red, :thickness => 5
    }

    ## Create a temporary file and save the output image there
    temp = Tempfile::open(['facerecog', '.jpg'], :encoding => 'ascii-8bit')
    img.save(temp.path)
    ## Render the saved image
    send_file temp.path, :type => 'image/jpeg', :disposition => 'inline'
    ## Close and delete the temporary file
    temp.close
  end


end
