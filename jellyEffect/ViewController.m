//
//  ViewController.m
//  jellyEffect
//
//  Created by rockfintech on 2021/4/8.
//

#import "ViewController.h"
#import "CuteView.h"
#import "MytableView.h"
#define appWidth CGRectGetWidth([[UIScreen mainScreen] bounds])
#define appHight CGRectGetHeight([[UIScreen mainScreen] bounds])
@interface ViewController ()<CuteViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    MytableView * tableView;
    CuteView * cuteView;
    UIView * subView;
    BOOL isCute;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 
    [self methodTwo];
}


- (void)methodTwo
{
    cuteView = [[CuteView alloc] initWithFrame:CGRectMake(0, 0, appWidth, 170)];
    cuteView.backgroundColor = [UIColor redColor];
    cuteView.cuteDelegate = self;
    [self.view addSubview:cuteView];
    
    isCute = YES;
    cuteView.headerImage.image = [UIImage imageNamed:@"cute.jpg"];
    
    tableView = [[MytableView alloc]initWithFrame:CGRectMake(0, 0, appWidth, appHight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.bounces = NO;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.tableHeaderView = cuteView;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [tableView addGestureRecognizer:pan];
}
- (void)handlePanAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:tableView];
    if (point.y > 0) {
        if (isCute == YES) {
            [cuteView handlePanAction:pan];
        }
    }
}


- (void)backMeWithHeaderCenterY:(CGFloat)centerY
{
    if (centerY == 1000) {
        cuteView.frame = CGRectMake(0, 0, appWidth, 170);
        tableView.tableHeaderView = cuteView;
        [tableView reloadData];
    }
    else
    {
        cuteView.frame = CGRectMake(0, 0, appWidth, centerY + 65);
        tableView.tableHeaderView = cuteView;
        
    }
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"个人中心%ld",(long)indexPath.row];
    
    
    return cell;
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",tableView.contentOffset.y);
    if (tableView.contentOffset.y > 0) {
        isCute = NO;
    }
    if (tableView.contentOffset.y == 0) {
        [self performSelector:@selector(canCute) withObject:nil afterDelay:0.1];
    }
}

- (void)canCute
{
    isCute = YES;
}


@end
