//
//  HomeViewController.m
//  UUBabyBluetoothDemo
//
//  Created by lhn on 17/1/5.
//  Copyright © 2017年 lhn. All rights reserved.
//

#import "HomeViewController.h"
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *peripherals;
    NSMutableArray *peripheralsAD;
    BabyBluetooth *baby;
}

@property(strong,nonatomic)UITableView *tableview;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableview];
    NSLog(@"viewDidLoad");
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc]init];
    peripheralsAD = [[NSMutableArray alloc]init];
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
}


#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
            //扫描设备 然后读取服务,然后读取characteristics名称和值和属性，获取characteristics对应的description的名称和值
            baby.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin;
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
        
    }];
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
    }];
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
    }];
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
        //找到cell并修改detaisText
        for (int i=0;i<peripherals.count;i++) {
            UITableViewCell *cell = [weakSelf.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.textLabel.text == peripheral.name) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)peripheral.services.count];
            }
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置查找设备的过滤器
    
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
        
        
        //BabyBluetooth中指定services
        NSMutableArray *servicedUUID = [NSMutableArray arrayWithObject:[CBUUID UUIDWithString:@"FFF0"]];
        
        if([servicedUUID isEqual:[CBUUID UUIDWithString:@"0xFFF0"]]) {
            NSLog(@"qwertyuikjhgfcdxscvbnhhahah哈哈哈哈");
        }
        //设置babybluetooth运行时参数
        [baby setBabyOptionsWithScanForPeripheralsWithOptions:nil connectPeripheralWithOptions:nil scanForPeripheralsWithServices:servicedUUID discoverWithServices:nil discoverWithCharacteristics:nil];
        
        
        if (peripheralName.length >1) {
            return YES;
        }
        return NO;
    }];

    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    //    [baby setBlockOnCancelPeripheralConnectionBlock:^(CBCentralManager *centralManager, CBPeripheral *peripheral) {
    //        NSLog(@"setBlockOnCancelPeripheralConnectionBlock");
    //    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelPeripheralConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    //    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    //    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}


#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![peripherals containsObject:peripheral]){
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        [peripherals addObject:peripheral];
        [peripheralsAD addObject:advertisementData];
        [self.tableview insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)setTableview {
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, width, height - 20) style:UITableViewStyleGrouped];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tableview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"cell"];
    CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
    NSDictionary *ad = [peripheralsAD objectAtIndex:indexPath.row];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //peripheral名称 peripheral name
    NSString *localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
    if (!localName) {
        localName = peripheral.name;
    }
    cell.textLabel.text = localName;
    //信号和服务
    cell.detailTextLabel.text = @"读取中...";
    //找到cell并修改detaisText
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    if (serviceUUIDs) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)serviceUUIDs.count];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service"];
    }
    
    //次线程读取RSSI和服务数量
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripherals.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralViewContriller *vc = [[PeripheralViewContriller alloc]init];
    vc.currPeripheral = [peripherals objectAtIndex:indexPath.row];
    vc->baby = self->baby;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
