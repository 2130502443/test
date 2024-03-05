<%--<%@ page import="javax.servlet.http.HttpSession" %>--%>
<%--<%@ page import="postproject.entity.User" %>--%>
<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2022/10/25
  Time: 23:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--在当前页面登录之后，要刷新。--%>
<%--在当前页面退出登录后，不用刷新页面，只是组件要改变点击状态--%>

<%--在其他页面登录。但当前页面还是未登录状态时，不刷新的情况下依然保持游客状态--%>

<%--其他页面退出登录后，当前页面如果是登录状态，要退出登录状态--%>

<%--初始加载页面就判断一次session，调整页面状态并展示。--%>
<%--实际上发现在jsp本页面登录（ajax登录，返回时为了得到登录状态要刷新页面）得到session后，如果直接退出登录（ajax退登），在不刷新页面的情况下，无法判断session，组件也没法切换到游客状态。这里--%>
<%--直接在初始化时就判断一次session状态存给全局变量。组件通过全局变量判断当前页面状态是否为登录状态。相当于在当前页面没有刷新的情况下，里面的一系列组件都遵循当前页面的登录与退出状态。--%>
<%--如果在其他页面登录，当前页面不刷新还是一样是游客状态（可以继续在当前页面登录，重复提交登录表单并无大碍）。--%>
<%--如果当前为登录状态且没有刷新，其他页面退登。当前页面必须是非登录状态（点击任何组件触发）--%>
<%--这时候必须去后台确认一下登录状态，可能其他页面退出了，或者登录了其他用户（登录了其他用户无所谓，只要session在，让后台根据session找对应数据即可，本页面不提交任何user信息用于查询）--%>

<%--总结：初始加载根据session判断为游客还是用户初始化界面，然后设置全局变量boolean类型（用于组件展示逻辑）判断用户当前登录状态--%>
<%--，在当前页面登录（登录时要刷新一次页面），退登（修改组件状态即可）都要修改全局变量。然后触发涉及登录才能交互成功的组件的事件时，--%>
<%--（1）如果当前全局变量给的是登录状态，还要去后台 检查当前的实际状态（因为全局变量只能监控当前页面的状态，不刷新页面时是静态的，--%>
<%--可能用户在其他页面退登或者登录了其他账号，而当前 页面一无所知），如果检查完了发现是非登录状态，修改全局变量，并且把头像--%>
<%--等用于展示的组件修改成非登录状态。如果检查完了发现是登录 状态，就继续执行业务逻辑即可，头像什么的也不需要换（因为用户的信息是存在session--%>
<%--中的，查询和增删改查都是后台从session中拿的，前端不会影响它们的逻辑）--%>

<%--（2）如果当前全局变量给的是非登录状态，也不用额外处理，继续执行业务逻辑即可。（方法多样，因为游客本来权限就是最少的，不太会出问题）--%>
<%--    其实这种情况的处理方法有多种，要么就是也去后台查一下，如果是登录就回来把当前页面整个刷新--%>
<%--    要么就啥也不处理，继续保持当前的非登录状态，以后遇到跳转页面了，对应页面的jsp初始也会根据session判断逻辑的，不过这么处理必须在显示帖子简介业务时给后端提示是走游客路线的，不
然可能当前页面虽然全局变量非登录，但实际是已登录，然后查出登录状态（改变三连的样式）的帖子简介。--%>

<%--2022.11.8回来看这段逻辑真的漏洞百出，特别是ajax先查看状态然后返回给用户那段，现在相当于是将登陆状态确认分成2次请求了，--%>
<%--很容易出现第一次请求是登录状态，结果在发送第二次请求前用户切换到非登录状态，而错误进行第二次请求，最好还是保持登录状态确认和请求在一个请求中，现在只能再加过滤器处理了，直接去错误页面算了--%>
<%--设定游客为 data:{userType:-1}--%>

<%--目前标题跳转，话题跳转，导航栏跳转和导航栏搜索没有弄--%>
<%--懒加载与图片查看器viewer，链接：http://t.csdn.cn/amEQ9--%>
<%--懒加载插件使用 http://t.csdn.cn/QCd91--%>
<%--后端图片压缩工具thumbnailator http://t.csdn.cn/q8VfB--%>

<%--就算加上管理员逻辑也不变，就是在当前页面初始化和当前页面退登登录的时候需要加上对应的样式而已，所以如果在其他页面换登管理员，当前页面不刷新的话不能享受管理员待遇--%>


<%--关于图片优化，本项目的图片非常多，而且用户上传图片大多都几m起步，这样会导致页面加载非常慢，如果采用传统的转发，页面卡很久都没有
加载出来，帖子详情页面的帖子内容就是反例。最快出效果的方法最好感觉还是html页面先静态加载完毕显示到前端，然后所有动态数据都采用ajax
带过来，这样即使图片加载慢，其他数据和html节点也能加载出来，不至于整个页面都假死。图片优化方面，首先静态图片资源就得压缩一遍，保证静态
html加载速度，动态数据前端勉强用懒加载凑合但效果也不明显，
最后还是得用压缩图片。目前的图片渲染情况是：img初始化先放一张loading加载动画，然后懒加载上去覆盖加载动画的是缩略图，然后如果
用户点击图片查看器查看大图，再往后端请求原图。前端最好限制住输入图片的格式，网络图片类型非常多，不一定能对应得上压缩工具的格式要求，
目前后端使用的压缩工具处理png也不太行--%>

<%--2022.12.3 现在回看当初的想法过于肤浅，还是对前后端json交互的方法太陌生，现在初步学习Spring Security才发现之前写的登录验证多么幼稚
现在的改造想法是，还是保留islogin标志，标记为非登录状态一样直接走弹框，但标记为登录状态直接访问业务接口，到时后端对权限认证完执行完返回结果前端再根据结果渲染即可，之前的想法先去checklogin
真的搞笑--%>
<html>
<head>
    <title>原神社区</title>
    <%--    配置网页的默认基础路径，没有以/开头的路径都会自动加上这个路径作为前缀，一般不会影响到jsp中页面跳转的路径，因为那些都会以/开头，这个标签主要有利于把html页面直接部署到jsp上--%>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/resource/">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 引入 Bootstrap -->
    <link rel="stylesheet" href="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://cdn.staticfile.org/jquery/2.1.1/jquery.min.js"></script>
    <script src="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <%--    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/page/static_style/homepage.css">--%>
    <link type="text/css" rel="stylesheet" href="static_style/homepage.css">
    <link rel="stylesheet" href="static_style/login-motai.css">
    <link rel="stylesheet" href="post-icon/iconfont.css">
    <link rel="stylesheet" href="//unpkg.com/layui@2.6.8/dist/css/layui.css">
    <script src="//unpkg.com/layui@2.6.8/dist/layui.js"></script>
    <%--    <link href="http://v3.bootcss.com/examples/non-responsive/non-responsive.css" rel="stylesheet">--%>
    <%--    Animate.css动效库，这个比较好用--%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
    <%--        SliderCaptcha滑块验证码，不进后台，前端验证--%>
    <%--    <link rel="stylesheet"  href="outerResource/SliderCaptcha/disk/slidercaptcha.min.css">--%>
    <%--    <link rel="stylesheet" href="outerResource/SliderCaptcha/lib/font-awesome/css/font-awesome.min.css">--%>
    <%--    <script src="outerResource/SliderCaptcha/disk/longbow.slidercaptcha.min.js"></script>--%>



    <%--    viewer图片查看器相关包--%>
    <link rel="stylesheet" href="static_style/viewer.css">
    <script src="js/viewer.js"></script>

    <%--&lt;%&ndash;    懒加载&ndash;%&gt;--%>
    <%--    <script src="js/jquery.lazyload.js"></script>--%>
    <%--  --%>
    <%--<script src="js/constants-project.js"></script>--%>
    <%--<link rel="stylesheet" type="text/css" href="static_style/nav-header.css">--%>
    <%--<link rel="stylesheet" type="text/css" href="static_style/nav-footer.css">--%>
    <link rel="stylesheet" type="text/css" href="static_style/nav-headerV.css">
    <%--    <link rel="stylesheet" type="text/css" href="static_style/nav-headerV12.css" >--%>
    <link rel="stylesheet" type="text/css" href="static_style/nav-footerV.css">
    <link rel="stylesheet" type="text/css" href="static_style/tavernPage.css">
    <%@ include file="tipConstants.jsp"%>
    <%@ include file="tools.jsp"%>
    <%@ include file="nav.jsp"%>
    <%@ include file="AJCaptchaTool.jsp"%>


    <script>
        if(isLogin){       //初始页面登录状态控件
            <%--   登录状态处理--%>
            loginStatue()
        }else{
            <%--   未登录状态处理--%>
            notLoginStatue()
        }
        let start=1;    //页码
        let pages=0;    //总页数,是不断更新的值（因为可能其他用户同步发帖了），但当前页码是确定的
        let time = getNowTime();
        let viewer = null
        //点击发布帖子按钮
        $(function (){

            /**功能：调用该方法跳转到发帖者页面sendPost
             // 输入项（请求参数）：csrfToken，用于防止csrf攻击
             // 输出项：
             // 流程逻辑：跳转页面
             */
            $("#sendPost").click(function () {
                if(isLogin){            //如果是登录状态，还必须去后台确认一下登录状态，可能其他页面退出了，或者登录了其他用户（登录了其他用户无所谓，只要session在，让后台根据session找对应数据即可，本页面不提交任何user信息用于查询）
                    window.location.href="${pageContext.request.contextPath}/sendPost"   //点击发送帖子按钮后，如果是登录状态，则跳转到发帖页面

                }else{
                    //弹出登录模态框登录
                    $('#myModal').modal('show')   //打开模态框
                }
            })
        })

        function showMoreSpan(event){
            $("#showMore").html("加载中...");
            $("#showMore").removeAttr("href");
            showPost();
        }


        /**功能：管理员点击推送按钮将当前帖子推送到首页或者取消推送时发送请求给后端改变其帖    子状态。成功后改变帖子样式
         输入项（请求参数）：postId
         输出项：code（状态码），msg（后端返回的信息）
         流程逻辑：前端请求更改状态请求，后端返回更改状态是否成功的状态码*/
        //管理员点击推送按钮将当前帖子推送到首页或者取消推送
        function pushPost(event){
            event = event ? event : window.event;                                   //在IE/Opera中，用window.event写法，在Firefox里面, 用event写法。
            let obj = event.srcElement ? event.srcElement : event.target;
            if(isLogin){
                let $root = $(obj).closest(".message-box");
                let postId = $root.attr("data-postId")
                let userId = $root.attr("data-userId")
                $.ajax({
                    url:"${pageContext.request.contextPath}/post/changePostStatus",
                    type:"GET",
                    dataType : "json",
                    data:{post_id:postId},
                    success : function(data, textStatus, xhr) {
                        if (Number(data) < 0){
                            showMsg(data.msg)
                        }else{      //成功
                            showMsg(data.msg)
                            $root.remove();
                        }
                    },
                    error : function(data, textStatus, xhr) {
                        if(data.status == 401){  //说明没登录，需要弹框
                            //弹出登录模态框登录
                            $('#myModal').modal('show')   //打开模态框
                            isLogin = false
                            notLoginStatue();
                        }else{
                            showMsg(data.responseText.replaceAll("\"",""));
                        }

                    }

                })
                // if($(obj).text() == "推送"){
                //     $(obj).text()
                // }
            }else{
                notLoginStatue();
                $('#myModal').modal('show')   //打开模态框
            }

        }


        /**  功能：发送删除帖子请求，成功后将页面帖子删除
         输入项：postId(要删除帖子的id)，userId（当前帖子发送者的id）
         输出项：code（状态码），msg（后端返回的信息）
         流程逻辑：前端请求更改状态请求，后端返回更改状态是否成功的状态码
         调用后端接口：/post/deletePost*/
        function deletePost(event){
            event = event ? event : window.event;                                   //在IE/Opera中，用window.event写法，在Firefox里面, 用event写法。
            let obj = event.srcElement ? event.srcElement : event.target;
            if(isLogin){
                let $root = $(obj).closest(".message-box");
                let postId = $root.attr("data-postId")
                let userId = $root.attr("data-userId")

                $.ajax({
                    url:"${pageContext.request.contextPath}/post/deletePost",
                    type:"GET",
                    dataType : "json",
                    headers:{csrfToken:csrfToken},
                    data:{post_id:postId,post_user_id:userId},
                    success : function(data, textStatus, xhr) {
                        if (Number(data) <= 0){
                            showMsg(data.msg);
                        }else{
                            showMsg(data.msg);
                            $root.remove();
                        }

                    },
                    error : function(data, textStatus, xhr) {
                        if(data.status == 401){  //说明没登录，需要弹框
                            //弹出登录模态框登录
                            $('#myModal').modal('show')   //打开模态框
                            isLogin = false
                            notLoginStatue();
                        }else{
                            showMsg(data.responseText.replaceAll("\"",""));
                        }
                    }
                })
            }else{
                notLoginStatue();
                $('#myModal').modal('show')   //打开模态框
            }
        }



        //显示帖子，分页加载，或者滚轮加载
        function showPost(){   //status是上面所说的用来控制保持游客查询数据的阀门，-1为保持游客状态，1为让后台不用特殊处理,为了避免被外人修改用post请求
            let isFist = false;
            if(pages <= 0){
                isFist = true;
            }
            let option = 0;
            if(isLogin)
                option = OPTION_NOPTION;
            else
                option = OPTION_KEEPVISITOR;
            $.ajax({
                url:"${pageContext.request.contextPath}/post/showPost",
                type:"GET",
                // 默认按热门排序
                data:{startPage:start,time:time,limit:LIMIT_SHOWPOST,showType:SHOWTYPE_NEWTIME,status:PUST_POST,isDeleted:DELETED_NOT_STATUS,option:Number(option)},
                dataType:'json',    //只要这里写的是json，返回的字符串会被转换成json格式，下面的success就不需要再用Json.parse转json
                success(rs){
                    let $box = $("#post-box");
                    let html = '';
                    pages = rs.pages
                    start = rs.startPage
                    let result = rs.postMsg
                    if(rs != null && result!=null && result.length > 0){
                        //更新总页数和当前页码
                        // alert(rs.startPage)
                        // alert(JSON.stringify(rs))

                        for(let i = 0; i < result.length;i++) {
                            // alert("111")
                            //    append是往选中的标签的内部尾部添加，不过好像有些会自动加结束标签，反正大量添加还是先拼好再append比较好
                            html+='            <div class="message-box" data-postId="'+result[i].postId+'" data-userId="'+result[i].user.userId+'"> ';
                            html+='                <div class="user-message">';

                            html+='<a  target="_blank"  href="${pageContext.request.contextPath}/personalCenter/postList?id='+result[i].user.userId+'"><div class="head-picture"><img class="headImg" src="'+filterXSS(result[i].user.headerBase64)+'" onerror="defaultHeadImg(event)"></div></a>';

                            html+='                    <!--            点击跳转到个人中心-->'
                            html+='                    <div class="passage-username"><font>'+filterXSS(result[i].user.username)+'</font></div>';
                            html+='                    <!--            用户姓名-->'
                            html+='                    <div class="passage-time-model"><font>'+formatMsgTime(filterXSS(result[i].create_time))+'&nbsp;</font></div>';
                            html+='                    <!--            发布帖子时间-->'
                            html+='                    <div class="passage-time-model"><font>'+pageTypeStrMap.get(result[i].type)+'</font></div>';
                            html+='                    <!--            发布帖子标签-->'
                            html+='                    <div class="passage-time-model"><font>原神</font></div>';
                            html+='                    <!--            帖子所属于模块-->'

                            if(role == ADMIN){
                                html+='  <div class="dropdown">'
                                html+='          <!--            下拉菜单-->'
                                html+='          <span>更多</span>'
                                html+='      <div class="dropdown-content">'
                                html+='          <a href="javascript:void(0)" class="del" onclick="showConfirm(tip_delPost,deletePost,event)">删除</a>'
                                html+='          <a href="javascript:void(0)" class="del" onclick="showConfirm(tip_cancelPutPost,pushPost,event)">取消推送</a>'
                                html+='      </div>'
                                html+='  </div>'
                            } else if(userId == result[i].user.userId) {
                                html += '  <div class="dropdown">'
                                html += '          <!--            下拉菜单-->'
                                html += '          <span>更多</span>'
                                html += '      <div class="dropdown-content">'
                                html += '          <a href="javascript:void(0)" class="del" onclick="showConfirm(tip_delPost,deletePost,event)">删除</a>'
                                html += '      </div>'
                                html += '  </div>'
                            }
                            // 用户如果关注了发帖者要隐藏关注按钮
                            if (result[i].userIsFocus){
                                html+='                    <span class="attention" data-targetId="'+filterXSS(result[i].user.userId)+'" style="display: none">关注</span>'  ;    //超链接,关注用户
                            }else{
                                html+='                    <span class="attention" data-targetId="'+filterXSS(result[i].user.userId)+'" onclick="focusButtom(event)">关注</span>';
                            }
                            // alert("5555555555555")
                            html+='                </div>';

                            html+='                <div class="message-title">';
                            html+='                    <div class="passage-title">';
                            // target="_blank"为新开窗口
                            html+='                        <a  target="_blank" href="${pageContext.request.contextPath}/post/showPostDetails?post_id='+filterXSS(result[i].postId)+'"><h4>'+filterXSS(result[i].title)+'</h4></a>';
                            html+='                    </div>';
                            html+='                    <div class="passage-title">';
                            html+='                        <a  target="_blank" href="${pageContext.request.contextPath}/post/showPostDetails?post_id='+filterXSS(result[i].postId)+'"><h5>'+filterXSS(result[i].content)+'</h5></a>';
                            html+='                    </div>';
                            html+='                </div>';
                            html+='                <div class="message-picture" >';
                            // html+='                    <div class="user-picture"><img src="img/2.png"></div>'
                            // html+='                    <div class="user-picture"><img src="img/图2.jpg"></div>'
                            if (result[i].img != null){
                                for(let j=0; j <result[i].img.length;j++){
                                    // style="width: 300px;height: 400px"
                                    let tmpImg =  result[i].img[j];
                                    let reaImg = tmpImg.replace("/resetImg/","/postImg/")
                                    html+='                    <div class="user-picture"><img class="lazy"   data-real="'+ reaImg+'"  data-original="'+tmpImg+'"></div>';
                                }
                            }
                            // alert("2222222222")
                            html+='                </div>';
                            html+='                <div class="message-like">';
                            html+='                    <div class="like-left">'  ;    //话题超链接
                            //    <div class="message-modal">< a href=" ">绘忆星辰</ a></div>
                            // <div class="message-modal">< a href="#">原神</ a></div>
                            // <div class="message-modal">< a href="#">基尼太美</ a></div>
                            // <div class="message-modal">< a href="#">食不食油饼</ a></div>
                            if(result[i].tags!=null){   //有些地方是可能为空的，要留意
                                for (let j=0; j <result[i].tags.length;j++){
                                    html+='                       <div class="message-modal" ><a target="_blank" href="${pageContext.request.contextPath}/topicDetails/'+result[i].tags[j].tagId+'">'+filterXSS(result[i].tags[j].name)+'</a></div>';

                                }
                            }
                            html+='                    </div>'
                            html+='                    <div class="like-right">'
                            html+='                        <div style="display: inline-block" class="like-div">';
                            html+='                            <i class="iconfont">&#xe628;</i>';
                            html+='                            <span >'+Number(result[i].commentCount)+'</span>';
                            html+='                        </div>';
                            html+='                        <div style="display: inline-block"  class="like-div" >';
                            if(result[i].userIsLike){
                                html+='                            <i class="iconfont " style="color:#00c2fd " data-active=1 data-targetId="'+result[i].postId+'" onclick="likeClick(event)">&#xec7f;</i>';
                            }else{
                                html+='                            <i class="iconfont"  data-active=0 data-targetId="'+result[i].postId+'" onclick="likeClick(event)">&#xec7f;</i>';
                            }

                            html+='                            <span>'+Number(result[i].likes)+'</span>';
                            html+='                        </div>';
                            html+='                    </div>';
                            html+='                </div>';
                            html+='            </div>';
                            // alert(html);
                        }
                        if(start > pages){
                            html+='      <div class="load-more"> ';
                            html+='               <span><a href="javascript:void(0);">没有更多数据了</a></span>';
                            html+='       </div>';
                        }else{
                            // 结尾的加载更多

                            html+='      <div class="load-more"> ';
                            html+='               <span><a id="showMore" href="javascript:void(0);" onclick="showMoreSpan(event)">点击加载更多<i class="iconfont" style="font-size: 20px">&#xeb03;</i></a></span>';
                            html+='       </div>';
                        }

                    }else{
                        if(isFist){
                            //已经查询完所有数据
                            html+='      <div class="load-more"> ';
                            html+='               <span><a href="javascript:void(0);">没有更多数据了</a></span>';
                            html+='       </div>';
                        }

                    }

                    // alert(JSON.stringify(rs));
                    $box.children(".load-more").remove() //删除加载更多提示，因为上面已经拼接了
                    html = updateImg(html);
                    // $el = $(html);
                    $box.append(html);
                    // $("img.lazy",$el).lazyload({effect: "fadeIn"});     //img标签下的class是lazy的元素，对$el即新拼接上的html选择，并进行懒加载
                    viewer.update();        //每次异步完了都要对图片查看器更新，因为这个查看器默认值找一次，不更新后续异步到的数据就不会显示
                },
                error:function (xhr,status,error){
                    showMsg(data.responseText.replaceAll("\"",""));
                }
            })
        }

        function focusButtom(event){
            event = event ? event : window.event;
            let obj = event.srcElement ? event.srcElement : event.target;
            if(isLogin){
                let targetId = $(obj).attr("data-targetId");
                if(targetId == null){
                    targetId = $(obj).closest(".attention").attr("data-targetId")
                }
                // let targetId = $(obj).attr("data-targetId");
                let data = {"entityId":targetId,"entityType":USER_TYPE}


                $.ajax({            //发送请求实现对应的关注业务
                    url: "${pageContext.request.contextPath}/user/changeFocus",
                    type:"POST",
                    dataType : "json",
                    data:{data:JSON.stringify(data)},
                    success : function(data, textStatus, xhr){
                        $("span.attention").each(function (i,span){
                            if($(span).attr("data-targetId")==targetId){
                                $(span)[0].classList.add('animate__animated', 'animate__fadeOut');
                            }
                        })
                    },
                    error : function(data, textStatus, xhr) {
                        if(data.status == 401){  //说明没登录，需要弹框
                            //弹出登录模态框登录
                            $('#myModal').modal('show')   //打开模态框
                            isLogin = false
                            notLoginStatue();
                        }else{
                            showMsg(data.responseText.replaceAll("\"",""));
                        }

                    }
                })


            }else{
                //弹出登录模态框登录
                $('#myModal').modal('show')   //打开模态框
                notLoginStatue();
            }
        }

        //点击点赞按钮
        function likeClick(event){      //事件源不一定是绑定事件的元素，可能是其子元素等，比如这里就是

            event = event ? event : window.event;                                   //在IE/Opera中，用window.event写法，在Firefox里面, 用event写法。
            let obj = event.srcElement ? event.srcElement : event.target;
            if(isLogin){
                let $likeIcon = $(obj)
                let $count = $(obj).next()
                let entityUserId =  $(obj).closest(".message-box").attr("data-userId");
                var data = {"entityId":$likeIcon.attr("data-targetId"),"entityType":1,"entityUserId":entityUserId};
                $.ajax({            //发送请求实现对应的点赞和取消点赞事务
                    url: "${pageContext.request.contextPath}/user/changeLikeToPost",
                    type:"POST",
                    dataType : "json",
                    data:{data:JSON.stringify(data),entityUserId:entityUserId},
                    success : function(data, textStatus, xhr){
                        if($likeIcon.attr("data-active")==0){     //用户要点赞
                            $likeIcon.css("color",'#00c2fd')
                            $count.text(parseInt($count.text())+1)
                            $likeIcon.attr("data-active",1)
                        }else{    //已点赞状态,此时用户要取消点赞
                            $likeIcon.css("color","")
                            $count.text(parseInt($count.text())-1)
                            $likeIcon.attr("data-active",0)
                        }
                    },
                    error : function(data, textStatus, xhr) {
                        if(data.status == 401){  //说明没登录，需要弹框
                            //弹出登录模态框登录
                            $('#myModal').modal('show')   //打开模态框
                            isLogin = false
                            notLoginStatue();
                        }else{
                            showMsg(data.responseText.replaceAll("\"",""));
                        }

                    }
                })
            }else{
                //弹出登录模态框登录
                $('#myModal').modal('show')   //打开模态框
                notLoginStatue();
            }

        }


        function showTags(){
            $.ajax({
                url:"${pageContext.request.contextPath}/tag/getTagMsg",
                type:'GET',
                dataType:'json',
                data:{'type':null,'status':TAG_PUSH_STATUS,'startPage':1,'limit':LIMITTAGS,'userId':userId},
                success:function (result){
                    let html='';
                    let tags = result.data;
                    if (tags.length >0){
                        for (let i = 0; i < tags.length; i++) {
                            html+='   <div class="inform-message">'
                            html+='       <div class="inform-message-profession">'
                            html+='           <a target="_blank" href="${pageContext.request.contextPath}/topicDetails/'+tags[i].tag.tagId+'"><img onerror="defaultHeadImg(event)" src="'+tags[i].tag.imgSrc+'"><font>'+tags[i].tag.name+'</font></a>'
                            html+='       </div>'
                            html+='   </div>'
                        }
                    }
                    $(".inform-box").append(html);
                },
                error:function (data,status,xhr){
                    showMsg(data.responseText.replaceAll("\"",""));
                }
            })


        }


        $(function (){
            // viewerjs的初始化，ajax更新图片的话记得在ajax最后加上 viewer.update()来更新查看器。这款
            //图片查看器原理是通过遍历得到当前viewer的子节点包含img的所有图片然后一并展示。

            viewer = new Viewer(document.getElementById('post-box'), {   //千万别写出let viewer了，这个必须是全局的，不然后续调不了这个查看器（现在是在onload的函数域）
                //如果是AJAX生成的图片，必须要加这段代码
                url: 'data-real',
                show:function(){
                    viewer.update();
                },

                navbar:false,           //隐藏缩略图导航
                toolbar:false ,         //隐藏工具栏
                title:false,
                // initialViewIndex:false
                zIndex:10000,   //调高优先级
            });

            // text-decoration: none;
            // font-weight: bold;
            // color: white;
            // background-color: #474a58;
            $("#linkHome").attr("href","javascript:void(0)").css("text-decoration","none").css("font-weight","bold").css("color","white").css("background-color","#474a58");

            showPost();
            showTags()
        })
    </script>

</head>

<body>
<%@ include file="nav-header-html-1.0.1.jsp"%>
<%--<%@ include file="nav-header-html.jsp"%>--%>
<div class="first-box" style="position: relative;top: 60px">
    <div class="lun-bo-tu">
        <div id="myCarousel" class="carousel slide">
            <!-- 轮播（Carousel）指标 -->
            <ol class="carousel-indicators">
                <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                <li data-target="#myCarousel" data-slide-to="1"></li>
                <li data-target="#myCarousel" data-slide-to="2"></li>
            </ol>
            <!-- 轮播（Carousel）项目 -->
            <div class="carousel-inner">
                <div class="item active">
                    <img src="img/8.jpg" alt="First slide" style="float:left">
                </div>
                <div class="item">
                    <img src="img/6.png" alt="Second slide" style="float:left">
                </div>
                <div class="item">
                    <img src="img/7.jpg" alt="Third slide" style="float:left">
                </div>
            </div>
            <!-- 轮播（Carousel）导航 -->
            <a class="left carousel-control" href="#myCarousel" role="button" data-slide="prev">
                <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="right carousel-control" href="#myCarousel" role="button" data-slide="next">
                <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>
    </div>
    <div class="post-massage" id="post-message">
        <div class="post-massage-center">
            <strong>发布中心</strong>
        </div>
        <button class="post-massage-button " id="sendPost">
            <i class="iconfont" style="padding-right: 15px">&#xe601;
            </i><strong>发布帖子</strong>
            <i class="iconfont" style="padding-left: 15px">&#xeb03;</i>

        </button>
        <div><span class="post-massage-font">讨论、分析、攻略、同人文</span></div>
        <button class="post-picture-button">
            <i class="iconfont" style="padding-right: 15px;">&#xe63e;</i>
            <strong >发布图片</strong>
            <i class="iconfont" style="padding-left: 15px">&#xeb03;</i>
        </button>
        <div><span class="post-massage-font">绘画、COS、手工、表情包</span></div>
        <hr style="margin-top: 10px">
        <div class="small-lun-bo">
            <div id="myCarousel3" class="carousel slide">
                <!-- 轮播（Carousel）指标 -->
                <ol class="carousel-indicators">
                    <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                    <li data-target="#myCarousel" data-slide-to="1"></li>
                    <li data-target="#myCarousel" data-slide-to="2"></li>
                </ol>
                <!-- 轮播（Carousel）项目 -->
                <div class="carousel-inner">
                    <div class="item active">
                        <img src="img/小轮播1.jpg" alt="First slide">
                    </div>
                    <div class="item">
                        <img src="img/小轮播图2.jpg" alt="Second slide">
                    </div>
                    <div class="item">
                        <img src="img/小轮播3.jpg" alt="Third slide">
                    </div>
                </div>
                <!-- 轮播（Carousel）导航 -->
                <a class="left carousel-control" href="#myCarousel3" role="button" data-slide="prev">
                    <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
                    <span class="sr-only">Previous</span>
                </a>
                <a class="right carousel-control" href="#myCarousel3" role="button" data-slide="next">
                    <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                    <span class="sr-only">Next</span>
                </a>
            </div>
        </div>
    </div>
</div>
<!--<div>-->
<!--    &lt;!&ndash;点击小火火箭回到顶部&ndash;&gt;-->
<!--    <a href="#navbar-padding">-->
<!--        <img src="img/锚点.png" class="maodian">-->
<!--    </a>-->
<!--</div>-->
<div class="second-box" style="position: relative;margin-bottom: 50px">
    <%--    <div id="view">--%>
    <%--        <img src="img/妮露.jpg">--%>
    <%--    </div>--%>

    <div class="post-box" id="post-box">
        <%--                帖子简介，ajax--%>

    </div>


    <div class="inform-box">
        <!--      <div>-->
        <!--        &lt;!&ndash;                <hr>&ndash;&gt;-->
        <!--        &lt;!&ndash;点击小火火箭回到顶部&ndash;&gt;-->
        <!--        <a href="#navbar-padding">-->
        <!--          <img src="img/锚点.png" class="maodian">-->
        <!--        </a>-->
        <!--      </div>-->
        <div class="more-topics inform-message ">
            <div class="inform-message-profession">
                <span class="hot-topic">推荐话题</span>
                <span class="hot-more"><a target="_blank" href="${pageContext.request.contextPath}/topicList">更多&nbsp;&gt;</a></span>
            </div>
        </div>



        <%--        <div class="inform-message">--%>
        <%--            <div class="inform-message-profession">--%>
        <%--                <a href="#"><img src="img/劫火.jpg"><font>虚空鼓动，劫火高扬</font></a>--%>
        <%--            </div>--%>
        <%--        </div>--%>

    </div>
</div>
<%@ include file="nav-footer-html-1.0.1.jsp"%>
<%--<%@ include file="nav-footer-html.jsp"%>--%>

<%--</div>--%>
</body>
</html>