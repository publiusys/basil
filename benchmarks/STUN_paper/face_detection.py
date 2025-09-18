import cv2
import sys
import time

# Get the video file name from command line argument
video_file = sys.argv[1]

# Load the cascades
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
eye_cascade = cv2.CascadeClassifier('haarcascade_eye.xml')

# Open the video file
cap = cv2.VideoCapture(video_file)

start_time = time.time()
frame_count = 0

while cap.isOpened():
    # Read a frame
    ret, frame = cap.read()
    if not ret:
        break # Break if no more frames

    frame_count += 1
    # Convert to grayscale (face detection works on grayscale)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Detect faces
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    # For each face found, try to detect eyes
    for (x,y,w,h) in faces:
        roi_gray = gray[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(roi_gray)

cap.release()
end_time = time.time()

total_time = end_time - start_time
fps = frame_count / total_time

print(f"Total Execution Time: {total_time:.3f} seconds")
print(f"Total Frames: {frame_count}")
print(f"Frames Per Second (FPS): {fps:.3f}")