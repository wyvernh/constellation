(define-module (mhdisk)
  #:use-module (guile-user)
  #:declarative? #f
  #:export (main))

(define (partition-filename drive n)
  (if (string-contains-ci drive "nvme")
      (string-append drive "p" (number->string n))
      (string-append drive (number->string n))))

(define (print-partition partition)
  (display (assoc-ref partition 'type))
  (display "   ")
  (display (assoc-ref partition 'size))
  (display "   ")
  (display (assoc-ref partition 'label))
  (newline))

(define (print-disk-from drive partitions n)
  (when (not (null? partitions))
    (display (partition-filename drive n))
    (display "     ")
    (print-partition (car partitions))
    (print-disk-from drive (cdr partitions) (+ n 1))))

(define (print-disk drive layout)
  (display drive)
  (display ":\n")
  (print-disk-from drive layout 1))

(define (partition-type type)
  (assoc-ref '(("vfat" . "ef00")
               ("ext4" . "8300")
               ("btrfs" . "8300")
               ("linux-swap" . "8200"))
             type))

(define (mkfs type)
  (assoc-ref '(;("vfat" . "mkfs.vfat")
               ("vfat" . "echo")
               ;("ext4" . "mkfs.ext4")
               ("ext4" . "echo")
               ;("btrfs" . "mkfs.btrfs")
               ("btrfs" . "echo")
               ;("linux-swap" . "mkswap")
               ("linux-swap" . "echo"))
             type))
;;testing, replace echo with sgdisk
(define (wipe-disk drive)
  (system* "echo" "-Z" drive)
  (system* "echo" "-g" drive))

(define (sgdisk-n-string partition n)
  (let ((size (assoc-ref partition 'size)))
    (if (eq? size "*")
        (string-append (number->string n) ":0:0")
        (string-append (number->string n) ":0:+" size))))

(define (sgdisk-t-string partition n)
  (let ((type (assoc-ref partition 'type)))
    (string-append (number->string n) ":" (partition-type type))))

(define (mk-partition drive partition n)
  (system* "echo"
           "-n" (sgdisk-n-string partition n)
           "-t" (sgdisk-t-string partition n)
           drive))

(define (mk-fs drive partition n)
  (system* (mkfs (assoc-ref partition 'type))
           (partition-filename drive n)))

(define (add-partition drive partition n)
  (if (zero? (mk-partition drive partition n))
      (if (zero? (mk-fs drive partition n))
          0
          2)
      1))

(define (partition-disk-from drive partitions n)
  (if (null? partitions)
      0
      (let ((code (add-partition drive (car partitions) n)))
        (if (zero? code)
            (partition-disk-from drive (cdr partitions) (+ n 1))
            code))))

(define (partition-disk drive layout)
  (partition-disk-from drive layout 1))

(define (run-mhdisk file-path)
  (load file-path)
  (if (not (defined? 'disk))
      (begin
        (display "Error: The file does not define a 'disk' variable\n")
        (exit 1))
      (let* ((disk-variable (eval 'disk))
             (drive (car disk-variable))
             (layout (car (cdr disk-variable))))
        (display "Partitioning according to disk layout:\n")
        (print-disk drive layout)
        (let ((code (partition-disk drive layout)))
          (if (zero? code)
              (begin
                (display "Successfully partitioned disk\n")
                (exit 0))
              (begin
                (if (= 1 code)
                    (display "sgdisk error\n")
                    (display "filesystem error\n"))
                (exit 1)))))))

(define (main args)
 (if (= (length args) 2)
     (run-mhdisk (car (cdr args)))
     (begin
       (display "Usage: mhdisk FILE_PATH\n")
       (display "FILE_PATH must be a full file path to a scheme file that exports a variable 'disk\n")
       (exit 1))))
