//
//  ViewController.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "ViewController.h"
#import "SensorsAnalyticsSDK.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *aaa;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(_lalal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    UITableView *lalaTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 375, 667)];
//    lalaTableView.delegate = self;
//    lalaTableView.dataSource = self;
//
//    [lalaTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
//    [self.view addSubview:lalaTableView];
    
//    [[SensorsAnalyticsSDK sharedInstance] login:@"aaa"];
//
//    UILabel *lla = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
//    lla.text = @"lalal";
//    lla.userInteractionEnabled = YES;
//
//    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_lalal)];
//    [lla addGestureRecognizer:tapGesture];
//
//    [self.view addSubview:lla];
    
//    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init]; [array addObject:@"First"];
//    [array release]; // 在这里会崩溃，因为array已经被释放，访问了不存在的地址
//    NSLog(@"Crash: %@", array.firstObject);
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = @"啦啦啦";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)_lalal{
    NSLog(@"1");
}

@end
