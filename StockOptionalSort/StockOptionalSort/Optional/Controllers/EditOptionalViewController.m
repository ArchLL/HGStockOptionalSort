//
//  EditOptionalViewController.m
//  TopMaster
//
//  Created by 中资北方 on 2017/6/7.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "EditOptionalViewController.h"
#import "OptionalEditCell.h"

#define topViewHeight 30
#define bottomViewHeight 40

@interface EditOptionalViewController () <UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView    * tableView;
@property (nonatomic, strong) UIButton       * deleteBtn;   //最下方的删除按钮
@property (nonatomic, strong) UIView         * bottomView;  //最下方的背景视图
@property (nonatomic, strong) NSMutableArray * deleteQueue; //删除队列，记录要删除项的下标(NSIndexPath)

@end

@implementation EditOptionalViewController

- (NSMutableArray *)deleteQueue {
    if (!_deleteQueue) {
        _deleteQueue = [NSMutableArray array];
    }
    return _deleteQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavi];
    [self setUI];
}

- (void)configureNavi {
    self.title = @"编辑";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = NAVIGATION_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]};
    //返回按钮
    UIButton * backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"返回"] forState:(UIControlStateNormal)];
    backButton.frame = CGRectMake(10, 30, 40, 25);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况，解决方法如下：
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

//返回上一界面
- (void)cancelAction {
    //1.清除数据库中的股票排序表
    [self.db jq_deleteAllDataFromTable:self.listTableName];
    //2.将自选股票加入数据库的自选排序表
    [self.db jq_insertTable:self.listTableName dicOrModelArray:self.optionalList];
    //3.返回
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setUI {
//创建头部视图
    UIView *topView = [[UIView alloc]init];
    topView.backgroundColor = kRGB(219, 219, 219);
    topView.frame = CGRectMake(0, 64, VIEW_WIDTH, topViewHeight);
    [self.view addSubview:topView];
    
    //名称代码
    UILabel *nameCodeLB = [[UILabel alloc]init];
    nameCodeLB.backgroundColor = [UIColor clearColor];
    nameCodeLB.text = @"名称代码";
    nameCodeLB.textAlignment = NSTextAlignmentLeft;
    nameCodeLB.font = [UIFont systemFontOfSize:15];
    [topView addSubview:nameCodeLB];
    [nameCodeLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView).offset(0);
        make.left.equalTo(topView).offset(48);
        make.width.mas_equalTo(100);
    }];
    
    //置顶
    UILabel *stickLB = [[UILabel alloc]init];
    stickLB.backgroundColor = [UIColor clearColor];
    stickLB.text = @"置顶";
    stickLB.textAlignment = NSTextAlignmentRight;
    stickLB.font = [UIFont systemFontOfSize:15];
    [topView addSubview:stickLB];
    [stickLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView).offset(0);
        make.left.equalTo(topView.mas_right).offset(-230);
        make.width.mas_equalTo(100);
    }];
    
    //拖动
    UILabel *dragLB = [[UILabel alloc]init];
    dragLB.backgroundColor = [UIColor clearColor];
    dragLB.text = @"拖动";
    dragLB.textAlignment = NSTextAlignmentRight;
    dragLB.font = [UIFont systemFontOfSize:15];
    [topView addSubview:dragLB];
    [dragLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView).offset(0);
        make.right.equalTo(topView.mas_right).offset(-10);
        make.width.mas_equalTo(50);
    }];
    
    //创建tableView
    self.tableView = ({ UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+topViewHeight, VIEW_WIDTH, VIEW_HEIGHT-64-topViewHeight-bottomViewHeight) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 46;
        [tableView  registerNib:[UINib nibWithNibName:@"OptionalEditCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OptionalEditCell"];
        [self.view addSubview:tableView];
        tableView;
    });
    self.tableView.editing=YES;//必须在外面设置tableView的编辑状态
    
    //创建底部视图 - 删除
    self.bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    _bottomView.frame = CGRectMake(0, VIEW_HEIGHT- bottomViewHeight, VIEW_WIDTH, bottomViewHeight);
    [self.view addSubview:_bottomView];
    //删除
    UIImageView *deteleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Optional_delete"]];
    deteleImageView.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:deteleImageView];
    [deteleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomView).offset(5);
        make.bottom.equalTo(_bottomView.mas_bottom).offset(-5);
        make.center.equalTo(_bottomView);
        make.width.mas_equalTo(bottomViewHeight-5);
        make.height.mas_equalTo(bottomViewHeight-10);
    }];
    //删除按钮
    self.deleteBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _deleteBtn.backgroundColor = [UIColor clearColor];
    [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:(UIControlEventTouchUpInside)];
    _deleteBtn.userInteractionEnabled = NO;//初始关闭删除按钮的交互
    [_bottomView addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(_bottomView).offset(0);
    }];
}

#pragma mark - 删除自选事件
- (void)deleteAction {
    //注意：界面上是支持多只股票删除的，同样服务器端也需要支持
    //1.删除服务器数据(删除成功后再执行下面的操作)
    NSLog(@"成功删除服务器数据");
    //2.删除数据源数据(这里也不能使用循环删除的方式，因为删除操作会引起数组容量的变化，导致数组越界等问题)
    //用下面这种方式删除多个不连续的元素
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];//用于记录_optionalList要删除元素的Indexes
    for (NSIndexPath *indexPath in _deleteQueue) {
        [indexes addIndex:(NSUInteger)indexPath.row];
    }
    [_optionalList removeObjectsAtIndexes:indexes];
    //3.删除界面
    [self.tableView reloadData];//刷新tableView后，对应的界面就不需要处理了。没找到一次删除多个cell的方法
    //4.清空删除队列
    [_deleteQueue removeAllObjects];
    //5.改变底部视图的颜色
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    //6.关闭按钮的交互
    _deleteBtn.userInteractionEnabled = NO;
}

#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionalList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionalEditCell"];
    if (self.optionalList.count > 0) {
        cell.model = self.optionalList[indexPath.row];
    }
    //置顶事件的回调
    WeakSelf(cell);
    weakcell.buttonClickBlock = ^(OptionalEditCell *cell) {
        //根据cell获取下标
        NSIndexPath *fromIndexPath = [self.tableView indexPathForCell:cell];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        id object = [_optionalList objectAtIndex:fromIndexPath.row];
        [_optionalList removeObjectAtIndex:fromIndexPath.row];
        [_optionalList insertObject:object atIndex:toIndexPath.row];
    };
    return cell;
}

//选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionalEditCell *cell = (OptionalEditCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell layoutSubviews];
    //1.判断此时是删除队列是否为空
    if (self.deleteQueue.count == 0) {
        //2.改变底部视图的颜色
        _bottomView.backgroundColor = NAVIGATION_COLOR;
        //3.打开删除按钮的交互
        _deleteBtn.userInteractionEnabled = YES;
    }
    //4.将改cell的下标加入到删除队列中
    [_deleteQueue addObject:indexPath];
}

//取消选中
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OptionalEditCell *cell = (OptionalEditCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell layoutSubviews];
    //1.将改cell的下标从删除队列中移除
    [_deleteQueue removeObject:indexPath];
    //2.判断此时是删除队列是否为空
    if (_deleteQueue.count == 0) {
        //3.改变底部视图的颜色
        _bottomView.backgroundColor = [UIColor lightGrayColor];
        //4.关闭按钮的交互
        _deleteBtn.userInteractionEnabled = NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    id object = [_optionalList objectAtIndex:fromIndexPath.row];
    [_optionalList removeObjectAtIndex:fromIndexPath.row];
    [_optionalList insertObject:object atIndex:toIndexPath.row];
}

@end
