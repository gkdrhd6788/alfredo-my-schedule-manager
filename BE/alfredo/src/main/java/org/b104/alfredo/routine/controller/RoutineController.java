package org.b104.alfredo.routine.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import org.b104.alfredo.routine.alarm.FcmRequest;
import org.b104.alfredo.routine.alarm.FirebaseCloudMessageService;
import org.b104.alfredo.routine.domain.BasicRoutine;
import org.b104.alfredo.routine.domain.Routine;
import org.b104.alfredo.routine.repository.BasicRoutineRepository;
import org.b104.alfredo.routine.request.RoutineIdsRequest;
import org.b104.alfredo.routine.request.RoutineRequestDto;
import org.b104.alfredo.routine.response.RoutineDto;
import org.b104.alfredo.routine.service.RoutineService;
import org.b104.alfredo.user.Domain.User;
import org.b104.alfredo.user.Repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

//TODO Transactional을 해야 되나??
@RestController
@RequestMapping("/api/routine")
@RequiredArgsConstructor
public class RoutineController {
    private final UserRepository userRepository;
    private final RoutineService routineService;
    private final BasicRoutineRepository basicRoutineRepository;
    private final FirebaseCloudMessageService firebaseCloudMessageService;
    private final Logger log = LoggerFactory.getLogger(RoutineController.class);
    @GetMapping("/all")
    public ResponseEntity<List<RoutineDto>> getRoutineList(@RequestHeader(value = "Authorization") String authHeader) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();
        Optional<User> user = userRepository.findByUid(uid);
        Long userId = user.get().getUserId();
        List<Routine> routineList = routineService.getAllRoutines(userId);
        List<RoutineDto> routineDtoList = new ArrayList<>();
        log.info("전체 루틴 정보");
        for (Routine r : routineList) {
            RoutineDto routineDto = RoutineDto.builder()
                    .id(r.getId())
                    .routineTitle(r.getRoutineTitle())
                    .startTime(r.getStartTime())
                    .days(r.getDays())
                    .alarmSound(r.getAlarmSound())
                    .memo(r.getMemo())
                    .build();
            routineDtoList.add(routineDto);
        }
        return ResponseEntity.ok().body(routineDtoList);
    }

    @GetMapping("/{routineId}")
    public ResponseEntity<RoutineDto> getRoutine(@PathVariable Long routineId){
        Routine routine = routineService.getRoutine(routineId);
        RoutineDto routineDto = RoutineDto.builder()
                .id(routine.getId())
                .routineTitle(routine.getRoutineTitle())
                .startTime(routine.getStartTime())
                .days(routine.getDays())
                .alarmSound(routine.getAlarmSound())
                .memo(routine.getMemo())
                .build();
        return ResponseEntity.ok().body(routineDto);
    }

//    String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo
//    routineTitle,startTime,days,alarmSound,memo
    @PostMapping
    public ResponseEntity<RoutineDto> createRoutine(@RequestHeader(value = "Authorization") String authHeader,@RequestBody RoutineRequestDto routineRequestDto) throws FirebaseAuthException {
        log.info("루틴 생성 시도");
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();

        Routine routine = routineService.createRoutine(uid,routineRequestDto.getRoutineTitle(),routineRequestDto.getStartTime(),routineRequestDto.getDays(),routineRequestDto.getAlarmSound(),routineRequestDto.getMemo());
        RoutineDto routineDto = RoutineDto.builder()
                .id(routine.getId())
                .routineTitle(routine.getRoutineTitle())
                .startTime(routine.getStartTime())
                .days(routine.getDays())
                .alarmSound(routine.getAlarmSound())
                .memo(routine.getMemo())
                .build();
        return ResponseEntity.ok().body(routineDto);
    }

    @PostMapping("/add-basic-routines")
    public ResponseEntity<Void> addBasicRoutines(@RequestHeader(value = "Authorization") String authHeader, @RequestBody RoutineIdsRequest request) throws FirebaseAuthException {
        String idToken = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();

        List<Long> basicRoutineIds = request.getBasicRoutineIds();
        routineService.addBasicRoutines(uid, basicRoutineIds);

        return ResponseEntity.ok().build();
    }

    //TODO Patch로 해보기
    @PatchMapping("/{routineId}")
    public ResponseEntity<RoutineDto> updateRoutine(@PathVariable Long routineId,@RequestBody RoutineRequestDto routineRequestDto){
        log.info("루틴 수정 시도");
        Routine routine = routineService.updateRoutine(
                routineId,
                routineRequestDto.getRoutineTitle(),
                routineRequestDto.getStartTime(),
                routineRequestDto.getDays(),
                routineRequestDto.getAlarmSound(),
                routineRequestDto.getMemo());

        RoutineDto routineDto = RoutineDto.builder()
                .id(routine.getId())
                .routineTitle(routine.getRoutineTitle())
                .startTime(routine.getStartTime())
                .days(routine.getDays())
                .alarmSound(routine.getAlarmSound())
                .memo(routine.getMemo())
                .build();
        return ResponseEntity.ok().body(routineDto);
    }

    //TODO ruturn값 설정?
    @DeleteMapping("/{routineId}")
    public void deleteRoutine(@PathVariable Long routineId) {
        log.info("루틴 삭제 시도");
        routineService.deleteRoutine(routineId);
    }

    //알림 테스트
    @PostMapping("/fcmAlarm")
    public ResponseEntity<String> pushMessage(@RequestBody FcmRequest fcmRequest) throws IOException {
        firebaseCloudMessageService.sendMessageTo(fcmRequest.getTargetToken(), fcmRequest.getTitle(), fcmRequest.getBody());
        return ResponseEntity.ok("Message sent successfully");

    }

}
