import React, { useEffect, useState } from "react";
import { Alert, StyleSheet, Text, NativeEventEmitter, NativeModules, View, TouchableOpacity } from "react-native";
import { useHeaderHeight } from '@react-navigation/elements';
import * as Progress from 'react-native-progress';
import { Double } from "react-native/Libraries/Types/CodegenTypes";

interface SeeSoModuleType {
  requestCameraPermission: (callback: (isGranted: boolean) => void) => void;
  initSeeSo: (licenseKey: string, option: boolean, callback: (error: string, isInit: boolean) => void) => void;
  startTracking: (callback: (message: string, isResult: boolean) => void) => void;
  isTracking: (callback: (message: string, isTracking: boolean) => void) => void;
  isCalibration: (callback: (message: string, isCalibrating: boolean) => void) => void;
  stopCalibration: (callback: (message: string, isStopped: boolean) => void) => void;
  startCalibration: (left: number, top: number, width: number, height: number, callback: (message: string, isResult: boolean) => void) => void;
  startCollectSamples: (callback: (error: string, started: boolean) => void) => void;
  stopTracking: (callback: (error: string, isStop: boolean) => void) => void;
  deinitSeeSo: (callback: (isDeinit: boolean) => void) => void;
  isInit: (callback: (isExist: boolean) => void) => void;
  checkCameraPermission: (callback: (isAuthorized: boolean) => void) => void;
}

const { SeeSoModule } = NativeModules as { SeeSoModule: SeeSoModuleType };

interface Position {
  x: number;
  y: number;
}

interface Dimensions {
  width: number;
  height: number;
}

interface CaliMode {
  is: boolean;
}

interface CaliTarget {
  nextX: number;
  nextY: number;
}

interface CaliProgress {
  progress: number;
}

export default function EyeTrackingPage() {
  const [dimensions, setDimensions] = useState<Dimensions>({ width: 0, height: 0 });
  const [position, setPosition] = useState<Position>({ x: 0, y: 0 });
  const [caliMode, setCaliMode] = useState<CaliMode>({ is: false });
  const [caliTarget, setCaliTarget] = useState<CaliTarget>({ nextX: -999, nextY: -999 });
  const [caliProgress, setCaliProgress] = useState<CaliProgress>({ progress: 0 });
  let headerHeight : Double;
  try {
    headerHeight = useHeaderHeight();
  } catch (error) {
    headerHeight = 0;
  }

  const requestPermission = async () => {
    //카메라 권한을 신청하는 함수.
    SeeSoModule.requestCameraPermission((isGranted) => {
      // 카메라 권한을 거부했을시 SeeSo를 사용할수 없음. 
      if (!isGranted) {
        Alert.alert("카메라 권한이 거부되었습니다.");
      } else {
        // 시소 initializing
        initSeeSo();
      }
    });
  };

  const initSeeSo = async () => {
    // todo "input your licenseKey"
    // isInit이 false일때 error가 String 형태로 나옴.
    // option이 true이면 Attention, Blink, Drowsiness 사용가능 다만 cpu를 더 사용함.
    let option = true;
    SeeSoModule.initSeeSo("input your licenseKey", option, (error, isInit) => {
      if(isInit) {
        startTracking();
      }else {
        Alert.alert(`인증 실패하였습니다. ${error}`);
      }
    })
  };

  const startTracking = async () => {
    // message, isResult
    // isResult가 false면 왜 실패인지 설명.
    SeeSoModule.startTracking((message, isResult) => {
      if(isResult) {
        console.log("request start tracking")
      }else {
        Alert.alert(`시선추적 시작에 실패하였습니다. ${message}`)
      }
    })
  };

  const isTracking = async () => {
    // tracking 여부를 나타내는 함수.
    SeeSoModule.isTracking((message, isTracking) => {
      console.log(`current isTracking : ${isTracking}`)
    })
  }

  const isCalibration = async () => {
    // calibration을 진행 중인지 여부를 나타내는 함수.
    SeeSoModule.isCalibration((message, isCalibrating) => {
      console.log(`current isCalibrating : ${isCalibrating}`)
    })
  }

  const stopCalibration = async () => {
    // Calibration 진행과정을 취소하는 함수.
    SeeSoModule.stopCalibration((message, isStopped) => {
      if (isStopped) {
        console.log(`Stop Calibration!`)
      }
    })
  }



  const handleButtonPress = () => {
    const margin = 25;
    // startCalibration(left, top, width, height, function(message, isResult));
    // tracking상태일때 호출해야 동작합니다. 
    // margin을 안주면 영역의 가장 끝에 점이 찍힘. 
    // headerHeight는 상단의 탑바 제외하기 위해서
    // isResult가 false일때 message에 왜 시작할수 없지는 이유 설명.
    SeeSoModule.startCalibration(margin, headerHeight + margin,  dimensions.width - margin*2, dimensions.height - margin*2, (message, isResult) => {
      if(isResult) {
        setCaliMode({is: true});
      }else {
        Alert.alert(`칼리브레이션 시작에 실패하였습니다. ${message}`)
      }
    })
  };

  useEffect(() => {
    const eventEmitter = new NativeEventEmitter(NativeModules.SeeSoEventEmitter);
    // SeeSoModule이 Init되었는지 여부 판단하는 함수.
    // isExist가 true면 initialized된 상태라 init을 할 필요가 없음.
    SeeSoModule.isInit((isExist) => {
      if(!isExist) {
        // 카메라 권한을 허용했는지 확인하는 함수. 
        SeeSoModule.checkCameraPermission((isAuthorized) => {
          console.log(`checkCameraPermission ${isAuthorized}`)
          // 승인됬을때 seeso를 initializing 한다.
          if(isAuthorized) {
            initSeeSo();
          } else {
            // 권한이 없을시 카메라 권한을 요청한다.
            requestPermission();
          }
        });
      }
    })
    // startTracking시에 gaze info를 받는다.
    // event에는 다음과 같은 변수가 있다. 
    // timestamp : ms 단위 utc
    // x,y gaze의 좌표. 
    // fixationX, fixationY 마지막 fixation 좌표.
    // trackingState -> "SUCCESS", "LOW_CONFIDENCE", "UNSUPPORTED", "FACE_MISSING", 현재는 SUCCESS만 신뢰하는 값으로 쓰임.
    // eyeMovementState -> "FIXATION", "SACCADE", "UNKNOWN" 시선의 상태, 고정상태인지 사카드 상태인지 알수 없는 상태인지를 나타냄.
    // screenState -> "INSIDE_OF_SCREEN", "OUTSIDE_OF_SCREEN", "UNKNOWN", 시선이 스크린안에 있는지 여부를 알려주는 변수.
    // leftOpenness, rightOpenness -> 0~1 사이의 값 (initSeeSo에서 option값 true일시 값 나옴.)
    const gazeSubscription = eventEmitter.addListener('onGaze', (event) => {
      console.log("onGaze")
      if (event.trackingState == "SUCCESS") {
        setPosition({
          x: event.x,
          y: event.y,
        });
      }
    });

    //시선 추적상태인지 여부를 알려주는 리스너
    // event에는 다음과 같은 변수가 있다.
    // isTracking 시선추적을 하는 중인지 아닌지 알려주는 변수
    // isTracking이 false일시에 errorMessage에서 이유가 들어있다. String 값
    const statusSubscription = eventEmitter.addListener('onStatus', (event) => {
      if(event.isTracking) {
        console.log("started tracking");
      } else {
        Alert.alert(`시선추적 중단. ${event.errorMessage}`)
      }
    });

    // calibration 과정에서 현재 보여줘야될 타겟의 위치를 알려주는 함수
    // nextX, nextY로 좌표위치를 알려주며, calibrationFinished시에 nan이 날라옴.
    const calibrationNextSubscription = eventEmitter.addListener('onCalibrationNext', (event) => {
      if(!isNaN(event.nextX) && !isNaN(event.nextY) ) {
        // 칼리브레이션 위치 설정.
        setCaliTarget({nextX: event.nextX, nextY: event.nextY});
        setTimeout(() => {
          // 현재 타겟의 프로그래스 초기화
          setCaliProgress({progress: 0});
          // 칼리브레이션 타겟을 그렷다고 알려주는 함수 0.5를 둬서 좀 더 안전하게 진행하도록 유도함.
          SeeSoModule.startCollectSamples((error, started) => {
            if (!started) {
              console.log(`error : ${error}`)
            }
          })
        }, 500);
      }
    });

    // 현재 타겟의 진행상태를 알려주는 리스너
    // event의 progress값으로 알수 있음 (0.0~1.0)
    const calibrationProgressSubscription = eventEmitter.addListener('onCalibrationProgress', (event) => {
      setCaliProgress({progress: event.progress})
    });

    // 칼리브레이션이 끝났을때를 알려주는 함수.
    // event에는 calibrationData라는 실수형 배열이 오는데 이 값을 setCalibrationData(datas, (message,isResult))넣으면 칼리브레이션 과정을 진행하지 않았도 됨.
    // 이때 이 정보는 칼리브레이션 과정당시의 자세, 사람에 따른 특정한 값이므로 자세나, 사용하는 사람이 달라졌다면 칼리브레이션을 진행하는것을 추천. 
    const calibrationFinishedSubscription = eventEmitter.addListener('onCalibrationFinished', (event) => {
      console.log(`calibration finished ${event.calibrationData}`)
      setCaliMode({is: false});
      setCaliTarget({nextX: -999, nextY: -999});
      setCaliProgress({progress: 0});
    });

    // 얼굴 관련값
    // timestamp 
    // score 0~1 값
    // imageWidth, imageHeight 카메라 이미지 사이즈
    // left, top, right, bottom 이미지 기준 얼굴 사각형 좌표. 
    // pitch, yaw, roll 얼굴 각도
    // centerX, centerY, centerZ 카메라로부터 얼굴 거리 (mm)
    const faceSubscription = eventEmitter.addListener('onFace', (event) =>{
      console.log(event.timestamp,", score : ", event.score);
    });

    // timestamp
    // isBlinkLeft, isBlinkRight, isBlink 왼쪽, 오른쪽, 양눈 (Bool)
    // leftOpenness, rightOpenness 0~1 값
    const blinkSubscription = eventEmitter.addListener('onBlink', (event) =>{
      console.log(event.timestamp,", isBlink : ", event.isBlink);
    });

    return () => {
      //stop tracking
      // isStop이 false면 왜 안돼지는 error출력해서 사용해볼것.
      SeeSoModule.stopTracking((error, isStop) => {
        
      })

      //SeeSoModule 사용종료시 호출 isDeinit이 false면 종료하지 못한것 (메모리 해제에 필요하므로 테스트 종료시 호출해줄것.)
      SeeSoModule.deinitSeeSo((isDeinit) => {
        
      });
      gazeSubscription.remove();
      faceSubscription.remove();
      statusSubscription.remove();
      calibrationNextSubscription.remove();
      calibrationProgressSubscription.remove();
      calibrationFinishedSubscription.remove();
      blinkSubscription.remove();
    }

  }, []);
    return (
      <View style={styles.container} onLayout={(event) => {
        const { width, height } = event.nativeEvent.layout;
        setDimensions({ width, height });
      }}>
        { !caliMode.is && (
          <View style={styles.verticalStack}>
            <TouchableOpacity onPress={() => handleButtonPress()}>
            <View style={styles.button}>
              <Text style={styles.buttonText}>CalibrationBtn</Text>
            </View>
            </TouchableOpacity>
          </View>
        )}
        {!caliMode.is && (
          <View style={{
            ...styles.gazeView,
            left: position.x - 5,
            top: position.y - headerHeight - 5,
            }} />
        )}
        {caliMode.is && (
          <View style={{ 
            position: 'absolute',
            left: caliTarget.nextX - 12.5,
            top: caliTarget.nextY - headerHeight - 12.5,
          }}>
            <Progress.Circle
              progress={caliProgress.progress}
              size={25}
              showsText={true}
              formatText={(progress) => `${Math.round(progress * 100)}%`}
              thickness={1}
              color="green" // 배경색 설정
              textStyle={{ fontSize: 10, color: "white" }} 
            />
            </View>
        )}
      </View>
    );
}

const styles = StyleSheet.create({
  container: {
      flex: 1,
      backgroundColor: '#fff',
      flexDirection: 'column',
    },
  verticalStack: {
    flex: 1,
    flexDirection: 'column', // 수직 스택 레이아웃
    alignItems: 'center',    // 자식 요소들을 중앙에 정렬
    justifyContent: 'center',
    // ... 기타 스타일 속성
  },
  button: {
    backgroundColor: 'green',  // 버튼 배경색 설정
    padding: 10,             // 패딩 설정
    borderRadius: 5,        // 버튼 모서리 둥글게
  },
  buttonText: {
    color: 'white',          // 버튼 텍스트 색상 설정
    fontSize: 16,            // 버튼 텍스트 크기 설정
    fontWeight: 'bold',      // 버튼 텍스트 굵기 설정
  },
  gazeView: {
    position: 'absolute',
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: 'blue',
  },
});