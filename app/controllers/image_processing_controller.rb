class ImageProcessingController < ApplicationController

  skip_before_filter :verify_authenticity_token ,:only=>[:adaptive, :facerecog, :faceswap]

  ## Front page
  def default
      render "image_processing/default"
  end



  ##
  ## 顔認識（顔認識機能の確認用）
  ##
  def adaptive

    ## Receive the posted data
    temp = Tempfile::open(['adaptive-in', '.jpg'], :encoding => 'ascii-8bit')
    while blk = request.body.read(4096)
      temp.write(blk)
    end
    img = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)  ##OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    temp.close



    ## Apply the face  recognition
    baseFaceDetector = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    baseFaceDetector.detect_objects(img, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
      img.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red, :thickness => 5
    }



    ## Apply the adaptive thresholding algorithm
    ##res = img.adaptive_threshold(255, :adaptive_method => :gaussian_c, :threshold_type => :binary, :block_size => 7, :param1 => 4)
    res = img

    ## Create a temporary file and save the output image there
    temp = Tempfile::open(['adaptive-out', '.jpg'], :encoding => 'ascii-8bit')
    res.save(temp.path)
    ## Render the saved image
    send_file temp.path, :type => 'image/jpeg', :disposition => 'inline'
    ## Close and delete the temporary file
    temp.close
  end





  ##
  ## 顔を認識してすり替える
  ##
  def facerecog
    ## Receive the base data
    temp = Tempfile::open(['adaptive-in', '.jpg'], :encoding => 'ascii-8bit')
    while blk = request.body.read(4096)
      temp.write(blk)
    end
    baseImage = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)
    temp.close


    ##### 合成用画像の取得 #####
    temp = File.open('app/assets/images/soccer.jpg', 'r')   ##今は手動で指定　将来的にはクライアントからview経由で渡してもらう
    composingImage = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)
    temp.close


    ## 合成用画像の顔認識（複数人対応）
    faceList = Array.new    ##合成用画像から顔を全て認識して格納

    faceDetector = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    faceDetector.detect_objects(composingImage, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
        tmpImg = OpenCV::IplImage.new rect.height, rect.width
        composingImage.set_roi rect
        composingImage.copy tmpImg
        composingImage.reset_roi
        faceList << tmpImg
    }


    ## ベース画像の顔認識、およびすり替え
    baseFaceDetector = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    baseFaceDetector.detect_objects(baseImage, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
        #img.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red, :thickness => 5
              baseImage.set_roi rect
              tmpImg = faceList[rand(faceList.length)] ##先ほど認識した顔からランダムに選んで貼り付け
              tmpImg = tmpImg.resize OpenCV::CvSize.new rect.height, rect.width
              tmpImg.copy baseImage
              baseImage.reset_roi
    }

    ## Create a temporary file and save the output image there
    temp = Tempfile::open(['facerecog', '.jpg'], :encoding => 'ascii-8bit')
    baseImage.save(temp.path)
    ## Render the saved image
    send_file temp.path, :type => 'image/jpeg', :disposition => 'inline'
    ## Close and delete the temporary file
    temp.close
  end

  def faceswap
    file1 = params[:file1]
    file2 = params[:file2]
    ## Receive the posted data
    temp = Tempfile::open(['adaptive-in1', '.jpg'], :encoding => 'ascii-8bit')
    while blk = file1.read(4096)
      temp.write(blk)
    end

    img = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)
    temp.close

    ##
    ##temp = File.open('app/assets/images/yoshio.jpg', 'r')
    temp = Tempfile::open(['adaptive-in2', '.jpg'], :encoding => 'ascii-8bit')
    while blk = file2.read(4096)
      temp.write(blk)
    end

    yoshio = OpenCV::IplImage.load(temp.path, OpenCV::CV_LOAD_IMAGE_COLOR)
    temp.close

    ## Apply the face  recognition to yoshio
    yoshio_face = nil
    
    yoshio_detect = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    yoshio_detect.detect_objects(yoshio, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
        #  yoshio.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red, :thickness => 5
        yoshio_face = OpenCV::IplImage.new rect.height, rect.width
        yoshio_rect = rect
        yoshio.set_roi rect
        yoshio.copy yoshio_face
        yoshio.reset_roi
    }

    ## Apply the face  recognition
    detector = OpenCV::CvHaarClassifierCascade::load("./haarcascade_frontalface_alt.xml")
    detector.detect_objects(img, :scale_factor => 1.1, :min_neighbors => 3).each { |rect|
        #img.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red, :thickness => 5
              img.set_roi rect
              yoshio_face = yoshio_face.resize OpenCV::CvSize.new rect.height, rect.width
              yoshio_face.copy img
              img.reset_roi
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
