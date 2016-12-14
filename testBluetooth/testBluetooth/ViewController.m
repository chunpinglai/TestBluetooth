//
//  ViewController.m
//  testBluetooth
//
//  Created by AbbyLai on 2016/12/14.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//  reference:http://www.saitjr.com/ios/core-bluetooth-read-write-as-central-role.html

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate> {
    CBCentralManager *myCentralManager;
    NSMutableArray *deviceArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    deviceArray = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!myCentralManager) {
        myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [myCentralManager stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)scanBtnAction:(id)sender {
    [myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    CBPeripheral *peripheral = [deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *selectedPeripheral = [deviceArray objectAtIndex:indexPath.row];
    [myCentralManager stopScan];
    [myCentralManager connectPeripheral:selectedPeripheral options:nil];
}

#pragma mark - CBCentralManager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Discovered %@", peripheral.name);
    [self addDeviceToList:peripheral];
}

- (void)addDeviceToList:(CBPeripheral *)peripheral {
    BOOL isIDExistInList = false;
    for (CBPeripheral *aPeripheral in deviceArray) {
        NSString *aPeripheralID = aPeripheral.identifier.UUIDString;
        NSString *currentID = peripheral.identifier.UUIDString;
        if ([aPeripheralID isEqualToString:currentID]) {
            isIDExistInList = true;
        }
    }
    
    if (!isIDExistInList) {
        [deviceArray addObject:peripheral];
        [_tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

#pragma mark - peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service uuid %@", service.UUID.UUIDString);
            NSLog(@"Discovering characteristics for service %@", service);
            [self showLocalNotification:service.UUID.UUIDString title:@"CBService UUID" service:nil];
            [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        [self showLocalNotification:characteristic.UUID.UUIDString title:@"CBCharacteristic UUID" service:service.UUID.UUIDString];
    }
}

- (void)showLocalNotification:(NSString *)msg title:(NSString *)titile service:(NSString *)service {
    NSString *str = [NSString stringWithFormat:@"\nCBService UUID:%@,%@:%@", service, titile, msg];
    if (!service) {
        str = [NSString stringWithFormat:@"\n%@:%@", titile, msg];
    }
    _textView.text = [_textView.text stringByAppendingString:str];
}

@end
