//
//  OptionalViewController.m
//  HGStockOptionalSort
//
//  Created by Arch on 2017/4/24.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "OptionalViewController.h"
#import "OptionalListCell.h"
#import "OptionalTopView.h"
#import "OptionalRightListCell.h"
#import "EditOptionalViewController.h"
#import "OptionalMarketModel.h"

static CGFloat const topViewHeight = 40;
static CGFloat const leftTableViewWidth = 90;
static CGFloat const rightUnitViewWidth = 100; //rightTableView cell中每一项的宽度
static NSString * const optionalListTableName = @"OptionalOrder"; //自选排序表名

@interface OptionalViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, strong) UIScrollView *rightScrollView; //rightTableView的背景
@property (nonatomic, strong) NSMutableArray *dataList; //自选股票数据列表
@property (nonatomic, strong) NSMutableArray *optionalList; //自选股票列表,存储股票代码
@property (nonatomic, strong) NSArray *dataTitles; //top标题
@property (nonatomic, strong) OptionalTopView *optionalTopView; //头部自定义view
@property (nonatomic,   copy) NSString *labels; //将股票列表里的代码拼接成字符串
@property (nonatomic,   copy) NSString *orderBy; //排序字段
@property (nonatomic,   copy) NSString *upOrDown;  //升序/降序
@property (nonatomic, strong) NSArray *orderFields; //排序字段
@property (nonatomic, strong) JQFMDB *db; //数据库-记忆排序队列
@property (nonatomic, strong) NSArray *stockCodeList; //股票代码队列,默认从服务器请求下来的自选股票代码队列，这里请求行情数据的时候使用的是本地数据，如果是网络数据就需要先获取自选列表

@end

@implementation OptionalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自选";
    self.navigationController.navigationBar.barTintColor = NAVIGATION_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //请求数据(非开盘期间进入这个页面也要重新请求一次)，因为请求数据是异步操作，所以线程开启放到请求数据成功或者失败后。
    [self requestResouse];
}

- (void)setUI {
    //添加头部标题视图
    [self.view addSubview:self.optionalTopView];
    //头部视图按钮点击事件的回调
    __weak typeof(self) weakSelf = self;
    weakSelf.optionalTopView.buttonClickBlock = ^(NSInteger tag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (tag == 1000) {
            //编辑按钮-进入排序编辑界面
            EditOptionalViewController *editVC = [[EditOptionalViewController alloc] init];
            editVC.hidesBottomBarWhenPushed = YES;
            editVC.optionalList = strongSelf.dataList;
            editVC.db = strongSelf.db;
            editVC.listTableName = optionalListTableName;
            [strongSelf.navigationController pushViewController:editVC animated:YES];
        } else if (tag == 1001) {
            //取消排序
            //1.排序字段置为nil
            strongSelf.orderBy = nil;
            //2.发起请求
            [strongSelf requestStockData];
        } else {
            //右边菜单按钮的响应-排序
            //1.获取对应button
            UIButton *menuBtn = [strongSelf.optionalTopView viewWithTag:tag];
            //2.指定排序字段
            strongSelf.orderBy = strongSelf.orderFields[tag - 100];
            //3.指定排序方式
            if (menuBtn.selected) {
                //降序
                strongSelf.upOrDown = @"-1";
            } else {
                //升序
                strongSelf.upOrDown = @"1";
            }
            //4.发起请求
            [strongSelf requestStockData];
        }
    };
    //头部视图内部scrollView滑动的回调
    weakSelf.optionalTopView.scrollViewBlock = ^(CGPoint offset) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.rightScrollView.contentOffset = offset;
    };
    //创建左边tableView
    [self createTableView];
}


#pragma mark - 请求资源(包括自选队列和行情数据)
- (void)requestResouse {
    //发起请求-先从数据库查找自选队列
    NSArray *array = [self.db jq_lookupTable:optionalListTableName dicOrModel:[OptionalMarketModel class] whereFormat:nil];
    [self.optionalList removeAllObjects];
    if (kArrayIsEmpty(array)) {
        //请求自选股票
        [self requestStockList];
    } else {
        for (OptionalMarketModel *model in array) {
            [self.optionalList addObject:model.Label];
        }
        self.labels = [_optionalList componentsJoinedByString:@","];
        //请求行情数据
        [self requestStockData];
    }
}

//请求自选股票队列
- (void)requestStockList {
    if (!kArrayIsEmpty(self.stockCodeList)) {
        NSMutableArray *sqliteArr = [NSMutableArray array];
        [self.optionalList removeAllObjects];
        for (NSDictionary *dic in self.stockCodeList) {
            OptionalMarketModel *model = [OptionalMarketModel mj_objectWithKeyValues:dic];
            [sqliteArr addObject:model];
            [self.optionalList addObject:model.Label];
        }
        //将自选股票加入数据库
        [self.db jq_insertTable:optionalListTableName dicOrModelArray:sqliteArr];
        //数组转化为字符串
        self.labels = [_optionalList componentsJoinedByString:@","];
        //请求行情数据
        [self requestStockData];
    }else {
        NSLog(@"请先添加自选股");
    }
}

//请求自选股票行情数据
- (void)requestStockData {
    //这里使用本地json数据
    //1.获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"optionalData" ofType:@"json"];
    //2.注意，根据路径获取NSData对象
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    //3.开始解析，如果json数据的最外层是数组，下面就用数组来接收，如果始字典就用字典接收
    NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //4.数据封装
    NSArray *temArr = responseObject[@"rows"];
    if (!kArrayIsEmpty(temArr)) {
        [self.dataList removeAllObjects];
        if (kStringIsEmpty(self.orderBy)) {
            //如果_orderBy不存在，按照数据库中存储的_labels顺序对其排序(用户自定义排序)
            for (int i = 0; i < self.optionalList.count; i++) {
                for (int j = 0; j < temArr.count; j++) {
                    OptionalMarketModel *model = [OptionalMarketModel mj_objectWithKeyValues:temArr[j]];
                    if ([self.optionalList[i] isEqualToString:model.Label]) {
                        [self.dataList addObject:model];
                    }
                }
            }
        }else {
            for (NSDictionary *dic in temArr) {
                OptionalMarketModel *model = [OptionalMarketModel mj_objectWithKeyValues:dic];
                [self.dataList addObject:model];
            }
            //如果 _upOrDown有值，将数据源重新排序(点击右边的菜单按钮排序-短暂排序)
            if ([self.upOrDown isEqualToString:@"1"]) { //升序
                self.dataList = [self getOrderArrayWithArray:self.dataList OrderBy:self.orderBy IsAscend:YES];
            }else if([self.upOrDown isEqualToString:@"-1"]){ //降序
                self.dataList = [self getOrderArrayWithArray:self.dataList OrderBy:self.orderBy IsAscend:NO];
            }
        }
    }
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

- (void)createTableView {
    //创建左边边tableView
    self.leftTableView = ({ UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topViewHeight, VIEW_WIDTH, VIEW_HEIGHT - topViewHeight - HGDeviceModelHelper.safeAreaInsetsTop - HGDeviceModelHelper.safeAreaInsetsBottom - 44 - 49) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = YES;
        [tableView registerNib:[UINib nibWithNibName:@"OptionalListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OptionalListCell"];
        [self.view addSubview:tableView];
        tableView;
    });
    
    //创建rightScrollView
    self.rightScrollView = ({ UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftTableViewWidth, topViewHeight, VIEW_WIDTH-leftTableViewWidth - 5, VIEW_HEIGHT - topViewHeight - HGDeviceModelHelper.safeAreaInsetsTop - HGDeviceModelHelper.safeAreaInsetsBottom - 44 - 49)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.contentSize = CGSizeMake(rightUnitViewWidth * self.dataTitles.count, 0);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        [self.view addSubview:scrollView];
        scrollView;
    });
    
    //创建righttableView
    self.rightTableView = ({ UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.rightScrollView.contentSize.width, self.rightScrollView.frame.size.height) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.backgroundColor = [UIColor whiteColor];
        [self.rightScrollView addSubview:tableView];
        tableView;
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        OptionalListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionalListCell"];
        if (self.dataList.count > 0) {
            cell.model = self.dataList[indexPath.row];
        }
        return cell;
    }else {
        static NSString *Identifier = @"OptionalRightListCell";
        OptionalRightListCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (!cell) {
            cell = [[OptionalRightListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OptionalRightListCell" withUnitCount:self.dataTitles.count];
        }
        if (self.dataList.count > 0) {
            cell.model = self.dataList[indexPath.row];
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.leftTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.rightTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionalMarketModel *model = self.dataList[indexPath.row];
    NSString * stockCode = model.Label;
    //进入股票界面
    NSLog(@"进入股票界面-股票代码：%@",stockCode);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.rightScrollView) {
        //左右滑动scrollView
        self.optionalTopView.rightScrollView.contentOffset = scrollView.contentOffset;
    }else {
        //上下滑动tableView
        self.leftTableView.contentOffset = scrollView.contentOffset;
        self.rightTableView.contentOffset = scrollView.contentOffset;
    }
}

/**
 //冒泡排序
 @param  array    数据源数组
 @param  orderBy  按那个字段排序
 @param  isAscend 是否是升序
 @return 排好序的数组
 */
- (NSMutableArray *)getOrderArrayWithArray:(NSMutableArray *)array OrderBy:(NSString *)orderBy IsAscend:(BOOL)isAscend {
    if (isAscend) {
        //升序
        for (int i = 0; i < array.count - 1; i++) {
            for (int j = 0; j < array.count - i - 1; j++) {
                OptionalMarketModel *fromModel = array[j];
                OptionalMarketModel *toModel = array[j+1];
                //模型转字典
                NSDictionary *fromDic = fromModel.mj_keyValues;
                NSDictionary *toDic   =   toModel.mj_keyValues;
                if ([fromDic[orderBy] floatValue] > [toDic[orderBy] floatValue]) {
                    OptionalMarketModel *tempModel = array[j];
                    array[j] = array[j+1];
                    array[j+1] = tempModel;
                }
            }
        }
    }else {
        //倒序
        for (int i = 0; i < array.count - 1; i++) {
            for (int j = 0; j < array.count - i - 1; j++) {
                OptionalMarketModel *fromModel = array[j];
                OptionalMarketModel *toModel = array[j+1];
                //模型转字典
                NSDictionary *fromDic =  fromModel.mj_keyValues;
                NSDictionary *toDic   =  toModel.mj_keyValues;
                if ([fromDic[orderBy] floatValue] < [toDic[orderBy] floatValue]) {
                    OptionalMarketModel *tempModel = array[j];
                    array[j] = array[j+1];
                    array[j+1] = tempModel;
                }
            }
        }
    }
    return array;
}

#pragma mark - Getters
- (JQFMDB *)db {
    if (!_db) {
        _db = [JQFMDB shareDatabase:@"stock.sqlite"];
        [_db jq_createTable:optionalListTableName dicOrModel:[OptionalMarketModel class]];
    }
    return _db;
}

- (NSMutableArray *)optionalList {
    if (!_optionalList) {
        _optionalList = [NSMutableArray array];
    }
    return _optionalList;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSArray *)stockCodeList {
    if (!_stockCodeList) {
        _stockCodeList = @[@{@"Label":@"SH600856"},@{@"Label":@"SH600039"},@{@"Label":@"SZ002564"},@{@"Label":@"SZ000002"}];
    }
    return _stockCodeList;
}

- (NSArray *)dataTitles {
    if (!_dataTitles) {
        _dataTitles = @[@"最新",@"涨幅",@"涨跌",@"涨速",@"总手",@"量比",@"开盘",@"昨收",@"最高",@"最低",@"委比",@"振幅"];
    }
    return _dataTitles;
}

- (NSArray *)orderFields {
    if (!_orderFields) {
        _orderFields = @[@"NewPrice",@"Gains",@"RiseFall",@"HigherSpeed",@"Hand",@"VolumeRatio",@"Open",@"LastClose",@"High",@"Low",@"AppointThan",@"Swing"];
    }
    return _orderFields;
}

- (OptionalTopView *)optionalTopView {
    if (!_optionalTopView) {
        _optionalTopView = [[OptionalTopView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, topViewHeight) withTitles:self.dataTitles];
    }
    return _optionalTopView;
}

@end
