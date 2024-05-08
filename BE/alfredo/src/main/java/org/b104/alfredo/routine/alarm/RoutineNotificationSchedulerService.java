package org.b104.alfredo.routine.alarm;

import lombok.extern.slf4j.Slf4j;
import org.b104.alfredo.routine.domain.Routine;
import org.b104.alfredo.routine.service.RoutineService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
@Slf4j
@Service
public class RoutineNotificationSchedulerService {
    private final RoutineService routineService;
    private final FirebaseCloudMessageService firebaseCloudMessageService;

    // 생성자 주입을 권장합니다
    public RoutineNotificationSchedulerService(RoutineService routineService, FirebaseCloudMessageService firebaseCloudMessageService) {
        this.routineService = routineService;
        this.firebaseCloudMessageService = firebaseCloudMessageService;
    }
    @Transactional
    @Scheduled(cron = "0 * * * * *") // 매 분마다 실행, 필요에 따라 조정하세요
    public void checkAndTriggerNotifications() throws IOException {
//        log.info("1분마다 실행 확인");
        List<Routine> routinesToNotify = routineService.getRoutinesToNotify();
        for (Routine routine : routinesToNotify) {
//            log.info("알림 토큰 잘받아오나 확인",routine.getUser().getFcmToken());
            firebaseCloudMessageService.sendMessageTo(
                    routine.getUser().getFcmToken(),
                    "Routine Reminder: " + routine.getRoutineTitle(),
                    "안녕하세요! 지금이 바로 " + routine.getRoutineTitle() + " 시간입니다"
            );
        }
    }
}