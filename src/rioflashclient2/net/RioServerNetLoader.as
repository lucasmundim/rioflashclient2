package rioflashclient2.net
{
  import __AS3__.vec.Vector;
  
  import org.osmf.media.MediaResourceBase;
  import org.osmf.net.NetConnectionFactoryBase;
  import org.osmf.net.NetLoader;
  import org.osmf.media.MediaType;
  import org.osmf.media.MediaTypeUtil;
  import org.osmf.media.URLResource;
  import org.osmf.utils.URL;  

  /**
   * RioServerNetLoader is a NetLoader that can load RioServer streams.
   *  
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion OSMF 1.0
   */
  public class RioServerNetLoader extends NetLoader
  {
    /**
     * Constructor.
     * 
     * @param factory the NetConnectionFactoryBase instance to use for managing NetConnections.
     * If factory is null, a NetConnectionFactory will be created and used. Since the
     * NetConnectionFactory class facilitates connection sharing, this is an easy way of
     * enabling global sharing, by creating a single NetConnectionFactory instance within
     * the player and then handing it to all RioServerNetLoader instances.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion OSMF 1.0
     */
    public function RioServerNetLoader(factory:NetConnectionFactoryBase=null)
    {
      super(factory);
    }
    
    /**
     * @private
     */
    override public function canHandleResource(resource:MediaResourceBase):Boolean
    {
      var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
      if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
      {
        return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
      }     

      /*
       * The rules for URL checking is outlined as below:
       * 
       * If the URL is null or empty, we assume being unable to handle the resource
       * If the URL has no protocol, we check for file extensions
       * If the URL has protocol, we have to make a distinction between progressive and stream
       *    If the protocol is progressive (file, http, https), we check for file extension
       *    If the protocol is stream (the rtmp family), we assume that we can handle the resource
       *
       * We assume being unable to handle the resource for conditions not mentioned above
       */
      var res:URLResource = resource as URLResource;
      var extensionPattern:RegExp = new RegExp("\.flv", "i");
      var url:URL = res != null ? new URL(res.url) : null;
      if (url == null || url.rawUrl == null || url.rawUrl.length <= 0)
      {
        return false;
      }
      if (url.protocol == "")
      {
        return extensionPattern.test(url.rawUrl);
      }
      if (url.protocol.search(/file$|http$|https$/i) != -1)
      {
        return (url.path == null ||
            url.path.length <= 0 ||
            url.path.indexOf(".") == -1 ||
            extensionPattern.test(url.rawUrl));
      }
      
      return false;
    }
    
    private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.VIDEO]);
    private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>
    ([
      "video/x-flv",
    ]);
  }
}
