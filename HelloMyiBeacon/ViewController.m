//
//  ViewController.m
//  HelloMyiBeacon
//
//  Created by Ｍasqurin on 2017/7/27.
//  Copyright © 2017年 Ｍasqurin. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locManager;
    
    CLBeaconRegion *beaconRegion1;
    CLBeaconRegion *beaconRegion2;
    CLBeaconRegion *beaconRegion3;
    
    
}
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UILabel *info3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Prepare locationManager,and ask user's permission
    locManager = [CLLocationManager new];
    locManager.delegate = self;
    [locManager allowsBackgroundLocationUpdates];
    [locManager requestAlwaysAuthorization];
//    NSUUID *beacon1UUID = [[NSUUID alloc]
//                           initWithUUIDString:@"84288BDA-6688-4567-88CC-7654AF068835"];
    NSUUID *beacon1UUID = [[NSUUID alloc]
                           initWithUUIDString:@"94278BDA-B644-4520-8F0C-720EAF059935"];
    NSUUID *beacon2UUID = [[NSUUID alloc]
                           initWithUUIDString:@"84278BDA-B644-4520-8F0C-720EAF059935"];
    NSUUID *beacon3UUID = [[NSUUID alloc]
                           initWithUUIDString:@"64278BDA-B644-4520-8F0C-720EAF059935"];
    
    //設定範圍 可設定 uuid major minor 藍牙範圍不夠大不用設範圍
    beaconRegion1 = [[CLBeaconRegion alloc]
                     initWithProximityUUID:beacon1UUID identifier:@"beacon1"];
    beaconRegion1.notifyOnExit = true;
    beaconRegion1.notifyOnEntry = true;
    beaconRegion2 = [[CLBeaconRegion alloc]
                     initWithProximityUUID:beacon2UUID identifier:@"beacon2"];
    beaconRegion2.notifyOnExit = true;
    beaconRegion2.notifyOnEntry = true;
    beaconRegion3 = [[CLBeaconRegion alloc]
                     initWithProximityUUID:beacon3UUID identifier:@"beacon3"];
    beaconRegion3.notifyOnEntry = true;
    beaconRegion3.notifyOnExit = true;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableSwitchValueChange:(id)sender {
    
    if ([sender isOn]) {
        //監控開啟
        [locManager startMonitoringForRegion:beaconRegion1];
        [locManager startMonitoringForRegion:beaconRegion2];
        [locManager startMonitoringForRegion:beaconRegion3];
    }else{
        [locManager stopRangingBeaconsInRegion:beaconRegion1];
        //監控關閉
        [locManager stopMonitoringForRegion:beaconRegion1];
        _info1.text = @"B1關閉";
        
        
        [locManager stopRangingBeaconsInRegion:beaconRegion2];
        [locManager stopMonitoringForRegion:beaconRegion2];
        _info2.text = @"B2關閉";
        
        [locManager stopRangingBeaconsInRegion:beaconRegion3];
        [locManager stopMonitoringForRegion:beaconRegion3];
        _info3.text = @"B3關閉";
    }
}

//建立方法呼叫本地通知
-(void) showLocalNotification:(NSString*)message{
    
    NSLog(@"showLocalNotification: %@",message);
    
    UILocalNotification *notify = [UILocalNotification new];
    //一般指定明確時間 跳出本地通知要做什麼 因為用本地時間會有時間差 設當下時間到程式碼執行就過了 所以設延後時間
    notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:.5];
    notify.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
}


#pragma mark - CLLocationManagerDelegate
//只有開始才呼叫
-(void)locationManager:(CLLocationManager *)manager
        didStartMonitoringForRegion:(CLRegion *)region{
    
    //監控再範圍內還是外
    [locManager requestStateForRegion:region];
}

//回報狀態 相對這個範圍r 狀態為何 進出被觸發
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state
             forRegion:(CLRegion *)region{
    
    NSString *message;
    
    if (state == CLRegionStateInside) {
        message = [NSString stringWithFormat:@"User is insided the region: %@",region.identifier];
        //region轉型
        [locManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }else{  //CLRegionStateOutside
        message = [NSString stringWithFormat:@"User is outsided the region: %@",region.identifier];
        [locManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
}
//配合偵測到圈圈內 持續測量距離
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray<CLBeacon *> *)beacons
              inRegion:(CLBeaconRegion *)region{
    //因為周遭裝置可能很多個 所以用array吐回來
    
    for (CLBeacon *beacon in beacons) {
        
        //proximity蘋果自己的演算法判斷遠近 accuracy精確度「m」
        // Decide proximity.
        NSString *proximityString;
        switch (beacon.proximity) {
            case CLProximityImmediate:
                proximityString = @"Immediate";
                break;
            case CLProximityFar :
                proximityString = @"Far";
                break;
            case CLProximityNear:
                proximityString = @"Near";
                break;
            default:
                proximityString = @"Unknown";
                break;
        }
        
        // Show info
        NSString *info = [NSString stringWithFormat:@"%@ ,%@,RSSI: %ld,Accuracy: %.6f",region.identifier,proximityString,beacon.rssi,beacon.accuracy];
        if ([region.identifier isEqualToString:beaconRegion1.identifier]) {
            _info1.text = info;
        }else if ([region.identifier isEqualToString:beaconRegion2.identifier]){
            _info2.text = info;
        }else if ([region.identifier isEqualToString:beaconRegion3.identifier]){
            _info3.text = info;
        }
    }
}

@end


















