ScreenShot = do ->
  gCxt = elements = imgConf = cutCanvas = null
  alsoResize = aspectRatio = true

  _init = ( conf ) ->
    elements = _create( conf )
    alsoResize = conf.isRatio or alsoResize
    aspectRatio = conf.isRatio or aspectRatio

    setTimeout ->
      _invokeJqueryPlugs( conf )
      return
    , 1500

    elements

  # 调用jQuery插件
  _invokeJqueryPlugs = ( conf ) ->
    $drag = $( '#drag' )

    $drag.draggable
      drag: ->
        data = _getCutData( this )
        _setView( data )
        _restrictDragPos( this, conf.root )

    $drag.resizable
      containment: '.big'
      aspectRatio: conf.isRatio or conf.aspectRatio or false
      minWidth: 100
      minHeight: 100
      resize: ->
        data = _getCutData( this )
        _setView( data )
    return

  # 自定义比例缩放
  _bindClipAsRatioEvent = ()->
    drag = $( '#drag' ).get( 0 )
    wClip = imgConf.wClip
    hClip = imgConf.hClip

    wClip.bind 'keyup', ()->
      _clipAsRatio( this.value, 'w' )
      _setView( _getCutData( drag ) )

    hClip.bind 'keyup', ()->
      _clipAsRatio( this.value, 'h' )
      _setView( _getCutData( drag ) )

  # 按比例缩放截图区域
  _clipAsRatio = ( val, type ) ->
    drag = $( '#drag' )
    wDrag = drag.width()
    hDrag = drag.height()

    if type is 'w' and val > wDrag
      drag.css
        width: wDrag * ( val / wDrag ) + 'px'
    if type is 'h' and val > hDrag
      drag.css
        height: hDrag * ( val / hDrag ) + 'px'
    return

  # 返回裁剪图片时所需要用的数据
  _getCutData = ( drag ) ->
    size = []
    item = $( drag )
    {left, top} = item.position()

    {sw, sh} =
      sw: item.width()
      sh: item.height()

    {sx, sy} =
      sx: left - imgConf.left
      sy: top - imgConf.top

    for item in elements
      if item.canvas?
        {dw, dh} =
          dw: item.canvas.width
          dh: item.canvas.height
        size.push {dw, dh}

    {
      img: imgConf.img
      sx: sx / imgConf.width * imgConf.orgWidth
      sy: sy / imgConf.height * imgConf.orgHeight
      sw: sw / imgConf.width * imgConf.orgWidth
      sh: sh / imgConf.height * imgConf.orgHeight
      dx: 0
      dy: 0
      dsize: size
    }

  # 显示被裁剪原图
  _setView = ( conf ) ->
    if conf.sx >= 0 and conf.sy >= 0
      for item, i in elements
        if item.canvas?
          item.cxt.clearRect( 0, 0, conf.dw, conf.dh )
          item.cxt.drawImage( conf.img, conf.sx, conf.sy, conf.sw, conf.sh, conf.dx, conf.dy, conf.dsize[ i ].dw, conf.dsize[ i ].dh )
    return

  # 当图像内容改变时，重新显示预览图
  _reDraw = ( src ) ->
    $drag = $( '#drag' )
    $img = $( imgConf.img ).attr( 'src', src )

  # 获取裁剪后预览图片的base64地址
  _getPreviwerSrcs = ( callback ) ->
    urls = []
    for item in elements
      if item.canvas?
        urls.push item.canvas.toDataURL( 'image/png' )
    callback?( urls );

  # 获取裁剪图片的base64地址
  _getCutImgSrc = ( callback ) ->
    src = elements[ elements.length-2 ].canvas.toDataURL( 'image/png' )
    callback?( src )

  # 限制拖拽元素的最大位移
  _restrictDragPos = ( drag ) ->
    item = $( drag )
    { left, top } = item.position()
    { width, height } =
      width: item.width()
      height: item.height()

    if left < imgConf.left
      item.css
        left: imgConf.left + 5
      return no

    if top < imgConf.top
      item.css
        top: imgConf.top + 5
      return no

    if left + width > imgConf.left + imgConf.width
      item.css
        left: left - ( ( left + width ) - ( imgConf.left + imgConf.width ) ) - 7
      return no

    if top + height > imgConf.top + imgConf.height
      item.css
        top: top - ( ( top + height ) - ( imgConf.top + imgConf.height ) ) - 7
      return no
    return yes

  # 创建canvas和拖拽对象
  _create = ( conf ) ->
    root = $( conf.root ).css
      lineHeight: $( conf.root ).height() + 'px'

    # 裁剪数据及事件
    ratio =
      wClip: ()->
        $( '<input type="text" value="0" >' )
      hClip: ()->
        $( '<input type="text" value="0" >' )

    # 生成被裁图片并加载拖拽层
    img = $( '<img>' ).attr( 'src', conf.src )
    img.attr( 'id', 'source-image' )
    img.addClass( 'cut-img' )
    img.bind 'load', ->
      _this = this
      $( this ).css
        width: 'auto'
        height: 'auto'
        verticalAlign: 'middle'

      setTimeout ->
        {orgWidth, orgHeight} =
          orgWidth: $( _this ).width()
          orgHeight: $( _this ).height()

        imgConf =
          img: _this
          orgWidth: orgWidth
          orgHeight: orgHeight

        $( _this ).css
          width: conf.root.width() + 'px'
          height: conf.root.height() + 'px'

        {left, top} = $( _this ).position()
        $.extend( imgConf,
          left: left
          top: top
          width: $( _this ).width()
          height: $( _this ).height()
        )

        if $( '#drag' ).length is 0
          drag = $( '<div>' ).attr( 'id', 'drag' ).css
            position: 'absolute'
            width: '100px'
            height: '100px'
            left: imgConf.width / 2 - 50 + 'px'
            top: imgConf.height / 2 - 50 + 'px'
            cursor: 'move'
            border: '3px dotted #fff'
            backgroundColor: 'rgba( 255, 255, 255, 0 )'
          drag.addClass( "drag" )
          root.append( drag )
        else
          drag = $( '#drag' )

        data = _getCutData( drag[ 0 ] )
        _setView( data )
        return
      , 1000
    root.append( img )

    # 创建canvas
    canvasAll = []
    if conf.multiImage? and conf.multiImage.length > 0
      for item, i in conf.multiImage
        $item = $( item )
        w = $item.width()
        h = $item.height()
        canvas = $( '<canvas>' ).get( 0 )
        canvas.width = w
        canvas.height = h
        canvasAll.push canvas

    if conf.max?
      canvas = $( '<canvas>' ).hide()
      canvas = canvas.get( 0 )
      canvas.width = conf.max.width
      canvas.height = conf.max.height
      canvasAll.push canvas

    if conf.multiImage? and conf.multiImage.length > 0
      for item, i in  canvasAll
        $wraper = $( conf.multiImage[ i ] )
        $wraper.append item
    if conf.max?
        root.append( canvasAll[ canvasAll.length-1 ] )

    # 做IE兼容
    if $.browser.msie and $.browser.version < 9
      # 此方法来自于flashcanvas.js
      # 用以初始化动态创建的canvas
      if conf.multiImage? and conf.multiImage.length > 0
        flashCanvasAll = []
        for val, i in canvasAll
          canvas = FlashCanvas.initElement( val )
          canvas.width =  conf.multiImage[ i ].width + 'px'
          canvas.height = conf.multiImage[ i ].height + 'px'
          flashCanvasAll.push canvas
        canvasAll = flashCanvasAll;

    # 返回数组对象
    elements = []
    for canvas in canvasAll
      item =
        cxt: canvas.getContext( '2d' )
        canvas: canvas
      item.cxt.fillStyle = 'transparent'
      elements.push item

    elements.push img
    return elements

  {
    init: _init
    reDraw: _reDraw
    getPreviewSrcs: _getPreviwerSrcs
    getCutImgSrc: _getCutImgSrc
  }
