//
//  ViewController.m
//  GetWebUrlIntro
//
//  Created by akixie on 16/3/1.
//  Copyright © 2016年 Aki.Xie. All rights reserved.
//

#import "ViewController.h"

#import "TFHpple.h"
#import "Tutorial.h"

#define RegularTaobao   @"item.taobao.com"
#define RegularJD       @"item.jd.com"



#pragma mark url type
typedef enum {
    MessageUrlTypeDefault = 0,
    MessageUrlTypeJD,
    MessageUrlTypeTaobao,
    MessageUrlTypeTmall,
    MessageUrlTypeDianPing,
    MessageUrlTypeMeiTuan,
    MessageUrlTypeCtrip
}MessageUrlType;

@interface ViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *urlLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webview12;
@property (strong, nonatomic) IBOutlet UIScrollView *sView;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (assign, nonatomic) MessageUrlType urlType;

@end

@implementation ViewController
- (IBAction)parseUrlEvents:(id)sender {
    
    NSString *urlSource = self.urlTextField.text;
    if (urlSource.length <= 0) {
        //为空给一个默认url
//        urlSource = @"https://item-paimai.taobao.com/pmp_item/526929043173.htm?s=pmp_detail&spm=a2129.7629195.1998344376.6.6nszl5";
        
        urlSource = @"https://item.taobao.com/item.htm?spm=a219e.1191392.1111.5.uqXla7&id=45261106601&scm=1029.newlist-0.1.50002766&ppath=&sku=&ug=#detail";
    }
    
    urlSource = @"http://item.jd.com/1268079336.html";


    NSError *error = NULL;
    NSString *pattern = [NSString stringWithFormat:@"(%@|%@)",RegularTaobao,RegularJD];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:urlSource options:0 range:NSMakeRange(0, [urlSource length])];
    NSUInteger matchCount = [matches count];
    if (matchCount) {
        for (NSUInteger matchIdx = 0; matchIdx < matchCount; matchIdx++) {
            NSTextCheckingResult *match = [matches objectAtIndex:matchIdx];
            NSRange matchRange = [match range];
            NSString *result = [urlSource substringWithRange:matchRange];
            NSLog(@"result : %@",result);
            if ([result isEqualToString:RegularJD]) {
                self.urlType = MessageUrlTypeJD;
            }else if ([result isEqualToString:RegularTaobao]){
                self.urlType = MessageUrlTypeTaobao;
            }
        }
    }
    else {
        NSLog(@"Nah... No matches.");
    }

    //淘宝URL解析；
//    [self productUrlParseTaobao:urlSource];
    
    //京东
//    urlSource = @"http://item.jd.com/1268079336.html";
//    [self productUrlParseJD:urlSource];
    
    
    //大众点评
//    urlSource = @"http://www.dianping.com/shop/22390170";
    urlSource = @"http://www.dianping.com/shop/23292477";
    self.urlTextField.text = urlSource;
    [self productUrlParseDianPing:urlSource];
    
    //饿了么 ..用JS生成的，目前无法获取
//    urlSource = @"https://www.ele.me/shop/332316";
//    [self productUrlParseELE:urlSource];
    
    //ctrip 酒店
//    urlSource =@"http://hotels.ctrip.com/international/904373.html?CheckIn=2016-03-04&CheckOut=2016-03-05&Rooms=2&childNum=2&PromotionID=&NoShowSearchBox=T&isfull=F&cbn=58&ecp=907574#ctm_ref=hi_0_0_0_0_lst_sr_1_df_ls_1_n_hi_0_0_0";
//    [self productUrlParseCtrip:urlSource];
    
    //美团
    //美团团购
//    urlSource = @"http://www.meituan.com/deal/29229429.html?mtt=1.topic%2Fnew.0.0.ilbpoubt";
    //美团商铺
//    urlSource = @"http://bj.meituan.com/shop/42728914#bdw";
//    [self productUrlParseMeituan:urlSource];
    
    
}
//美团
-(void)productUrlParseMeituan:(NSString*)urlSource{
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    //图片
    
    NSString *imgQueryString = @"//div[@class='deal-component-cover ui-slider']/img";
    NSArray *imgNodes = [tutorialsParser searchWithXPathQuery:imgQueryString];
    
    for (TFHppleElement *element in imgNodes) {
        NSDictionary *nodeDic = element.attributes;
        NSString *photoUrl = nodeDic[@"data-src"];
        NSLog(@"photoUrl : %@",photoUrl);
        NSURL *imageURL = [NSURL URLWithString:photoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        self.photoView.image = image;
    }
    
    //价格
    
    
    
    
    
}

//携程
-(void)productUrlParseCtrip:(NSString*)urlSource{
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    
    
}

//饿了么
-(void)productUrlParseELE:(NSString*)urlSource{
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    
    
}


//京东
-(void)productUrlParseJD:(NSString*)urlSource{
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    //价格
    NSString *priceQueryString = @"//strong[@id='jd-price']";
    NSArray *priceNodes = [tutorialsParser searchWithXPathQuery:priceQueryString];
    for (TFHppleElement *element in priceNodes) {
        NSArray *nodeArray = element.children;
        for (TFHppleElement *dic in nodeArray) {
            NSString *name = dic.tagName;
            NSString *priceStr = [NSString stringWithFormat:@"￥%@",dic.content];
            
            NSLog(@"priceStr : %@",priceStr);
            self.priceLabel.text = priceStr;
        }
    }
    
    //图片规则
    NSString *imgQueryString = @"//div[@class='jqzoom']/img";
    NSArray *imgNodes = [tutorialsParser searchWithXPathQuery:imgQueryString];
    
    for (TFHppleElement *element in imgNodes) {
        NSDictionary *nodeDic = element.attributes;
        NSString *photoUrl = nodeDic[@"src"];
        photoUrl = [NSString stringWithFormat:@"http:%@",photoUrl];
        NSLog(@"photoUrl : %@",photoUrl);
        NSURL *imageURL = [NSURL URLWithString:photoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        self.photoView.image = image;
    }
    
}

//大众点评
-(void)productUrlParseDianPing:(NSString*)urlSource{
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    //五星商户 1499条评论 人均：81元 | 口味：9.1 | 环境：9.1 | 服务：9.2
    NSString *infoQueryString = @"//div[@class='brief-info']/span";
    NSArray *infoNodes = [tutorialsParser searchWithXPathQuery:infoQueryString];
    NSMutableString *resultInfo = [[NSMutableString alloc] init];
    for (TFHppleElement *element in infoNodes) {
        
        NSDictionary *nodeDic = element.attributes;
        NSString *title = nodeDic[@"title"];//五星商户
        if (title && title > 0) {
            [resultInfo appendString:[NSString stringWithFormat:@"%@  ",title]];
        }
        NSArray *nodeArray = element.children;
        for (TFHppleElement *dic in nodeArray) {
            NSString *name = dic.tagName;
            [resultInfo appendString:[NSString stringWithFormat:@"%@  ",dic.content]];
        }
    }
    self.infoLabel.text = resultInfo;
    
    //图片url
    //图片规则1
    NSString *imgQueryString = @"//a[@class='J_main-photo']/img";
    NSArray *imgNodes = [tutorialsParser searchWithXPathQuery:imgQueryString];
    //图片规则2
    if (imgNodes.count == 0) {
        imgQueryString = @"//div[@class='photos']/a/img";
        imgNodes = [tutorialsParser searchWithXPathQuery:imgQueryString];
    }
    
    for (TFHppleElement *element in imgNodes) {
        NSDictionary *nodeDic = element.attributes;
        NSString *photoUrl = nodeDic[@"src"];
        NSLog(@"photoUrl : %@",photoUrl);
        NSURL *imageURL = [NSURL URLWithString:photoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        self.photoView.image = image;
    }
    
}

-(void)productUrlParseTaobao:(NSString*)urlSource{
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlSource]];
    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    [self getProductBaseInfo:tutorialsParser];
    
    //价格
    NSString *priceQueryString = @"//em[@class='tb-rmb-num']";
    NSArray *priceNodes = [tutorialsParser searchWithXPathQuery:priceQueryString];
    for (TFHppleElement *element in priceNodes) {
        NSArray *nodeArray = element.children;
        for (TFHppleElement *dic in nodeArray) {
            NSString *name = dic.tagName;
            NSString *priceStr = [NSString stringWithFormat:@"￥%@",dic.content];
            
            NSLog(@"priceStr : %@",priceStr);
            self.priceLabel.text = priceStr;
        }

        
    }
    
    //图片 淘宝ID: J_ImgBooth
    NSString *imgQueryString = @"//img";
    NSArray *imgNodes = [tutorialsParser searchWithXPathQuery:imgQueryString];
    for (TFHppleElement *element in imgNodes) {
        
        NSDictionary *nodeDic = element.attributes;
        NSString *imageId = nodeDic[@"id"];
        
        NSString *photoUrl = nodeDic[@"src"];
        
        if ([imageId isEqualToString:@"J_ImgBooth"] || [imageId isEqualToString:@"multi"]) {
            
            self.urlLabel.text = photoUrl;
            
            NSString *resultUrl = [NSString stringWithFormat:@"http:%@",photoUrl];
            NSLog(@"photoUrl : %@",resultUrl);
            
            NSURL *imageURL = [NSURL URLWithString:resultUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            
            
            self.photoView.image = image;
            
        }
    }
}

-(void)getProductBaseInfo:(TFHpple*)tutorialsParser{
    //标题
    NSString *titleQueryString = @"//title";
    NSArray *titleNodes = [tutorialsParser searchWithXPathQuery:titleQueryString];
    for (TFHppleElement *element in titleNodes) {
        NSArray *nodeArray = element.children;
        for (TFHppleElement *dic in nodeArray) {
            
            if (dic.tagName && [dic.tagName isEqualToString:@"text"]) {
                self.titleLabel.text = dic.content;
            }
        }
        
    }
    
    //简介
    NSString *tutorialsXpathQueryString = @"//meta";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    for (TFHppleElement *element in tutorialsNodes) {
        if (element == nil) {
            continue;
        }
        NSDictionary *nodeDic = element.attributes;
        NSString *nodeName = nodeDic[@"name"];
        
        NSString *nodeContent = nodeDic[@"content"];
        
        if ([nodeName isEqualToString:@"description"]) {
            NSLog(@"content : %@",nodeContent);
            // 6
            self.infoLabel.text = nodeContent;
            
        }
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _webview12.delegate = self;
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlSource]];
//    [_webview12 setUserInteractionEnabled:NO];
//    [_webview12 loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
//    [webView sizeToFit];
    
    webView.scrollView.scrollEnabled = NO;
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    self.sView.frame = frame;
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title
    
    NSString *content = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('meta')[0].getAttribute('content')"];
    
//    self.infoLabel.text = content;
//    description

    
//    var metas = document.getElementsByTagName('meta');
//    
//    for (var i=0; i<metas.length; i++) {
//        if (metas[i].getAttribute("property") == "video") {
//            return metas[i].getAttribute("content");
//        }
//    }
    
//    document.getElementsByTagName('META')
    
    self.titleLabel.text = title;
    
    NSString *currentURL = webView.request.URL.absoluteString;
    
//    NSString *shotUrl = [NSString stringWithFormat:@";http://tinyurl.com/api-create.php?url=%@",currentURL];
    
//    self.urlLabel.text = shotUrl;
    
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"reportMeta" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsCode];
    [webView stringByEvaluatingJavaScriptFromString:@"reportMeta()"];


//    NSString *link = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];

    

    NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
    NSString *currentHTML = [webView stringByEvaluatingJavaScriptFromString:lJs];
    
}

@end
