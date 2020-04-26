#!/bin/bash

rev=$(grep \$Revision dcraw.c | awk '{ print $2 }')

cat dcraw.c \
	| sed -e 's/argc == 1/0/' \
	| sed -re "s_case '[cIEDdjzPKT6h]'_//&_" \
	| sed -e 's/&& read_from_stdin/\&\&0/' \
	| sed -e 's/use_fuji_rotate=1/use_fuji_rotate=0/' \
	| sed -e 's/document_mode=0/document_mode=2/' \
	| sed -e 's/half_size=0/half_size=1/' \
	| sed -re 's/\((write_to_stdout|verbose)\)/(0)/' \
	| sed -re 's/setjmp\s*\(/0\&\&&/' \
	| sed -e 's_longjmp_abort();//&_' \
	| sed -e 's-bad_pixels (bpfile-//&-' \
	| sed -re '/CLASS/! s_merror_//merror_' \
	| sed -re '/CLASS/! s-parse_makernote-if(0)&-' \
	| sed -e 's/putenv/if(0)&/' > dcraw.tmp.c

patch <./dcraw.patch
emcc -Oz -g1 -flto -ffast-math -funroll-loops -finline-functions -fomit-frame-pointer \
	-s INVOKE_RUN=0 -s EXIT_RUNTIME=0 -s ALLOW_MEMORY_GROWTH=1 -s ASSERTIONS=0 -s TEXTDECODER=2 \
	-s ABORTING_MALLOC=0 -s DYNAMIC_EXECUTION=0 -s DOUBLE_MODE=0 -s DISABLE_EXCEPTION_CATCHING=1 \
	-s MEMFS_APPEND_TO_TYPED_ARRAYS=1 -s AGGRESSIVE_VARIABLE_ELIMINATION=0 \
	-s MINIMAL_RUNTIME=1 -s SINGLE_FILE=1 -s WASM=0 -DSMALL \
	-o dcraw.js -DNODEPS -Wno-warn-absolute-paths dcraw.tmp.c

cat dcraw.js \
	| sed -re 's/(var )?ENVIRONMENT_IS_\w+ =/\/\/off/' \
	| sed -re 's/ENVIRONMENT_IS_[A-Z]+/0/g' \
	| sed -re 's/^Module\["(\w+)"\] = \1;/\/\/&/' \
	| sed -re 's/Module\["(read|ENVI|extraStac|noInitialRun|onRuntimeIni|setStatus|setWindo|load|argum|preInit)/1\?0\:&/' \
	| sed -re 's/^Module\["(FS|preloadedImages|preloadedAudios|exit|abort|run|noExitR)/\/\/&/' \
	| sed -re 's/^Module\["(\w+)"\] = Module\.\1/Module.\1/' \
	| sed -re 's/^Module\.(\w.*) = Module\["\1"\]/Module.\1/' \
	| sed -e 's~typeof FS === "undefined"~0~g' \
	| sed -e 's~typeof Module==="undefined"~1~g' \
	| sed -e 's~var Module = Module;~ ~g' \
	| sed -e 's~typeof dateNow !== "undefined"~0~g' \
	| sed -e 's~function setErrNo~var setErrNo=function~' \
	| sed -e 's~_abort,~abort,~' \
	| sed -e 's~console.error~console.warn~' \
	| sed -e 's/createPreloadedFile:/& 0\&\&/' \
	| sed -e 's/createLazyFile:/& 0\&\&/' \
	| sed -e 's/forceLoadFile:/& 0\&\&/' \
	| sed -e 's/indexedDB:/& 0\&\&/' \
	| sed -e 's/DB_NAME:/& 0\&\&/' \
	| sed -e 's/DB_VERSION:/& 0\&\&/' \
	| sed -e 's/DB_STORE_NAME:/& 0\&\&/' \
	| sed -e 's/saveFilesToDB:/& 0\&\&/' \
	| sed -e 's/loadFilesFromDB:/& 0\&\&/' \
	| sed -e 's/getCompilerSetting:/K: 0\&\&/' \
	| sed -e 's/getAsmConst:/J: 0\&\&/' \
	| sed -e 's/generateStructInfo:/L: 0\&\&/' \
	| sed -e 's/calculateStructAlignment:/M: 0\&\&/' \
	| sed -e 's/functionPointers:/x:0\&\&/' \
	| sed -e 's/addFunction:/y:0\&\&/' \
	| sed -e 's/removeFunction:/z:0\&\&/' \
	| sed -e 's/warnOnce:/o:0\&\&/' \
	| sed -e 's/funcWrappers:/q:0\&\&/' \
	| sed -e 's/getFuncWrapper:/w:0\&\&/' \
	| sed -e 's/getSocketFromFD:/w:0\&\&/' \
	| sed -e 's/getSocketAddress:/s:0\&\&/' \
	| sed -e 's/getZero:/t:0\&\&/' \
	| sed -e 's/get64:/k:0\&\&/' \
	| sed -e 's/handleFSError:/k:0\&\&/' \
	| sed -e 's/analyzePath:/k:0\&\&/' \
	| sed -e 's/findObject:/j:0\&\&/' \
	| sed -e 's/createFolder:/r:0\&\&/' \
	| sed -e 's/createPath:/t:0\&\&/' \
	| sed -e 's/createFile:/q:0\&\&/' \
	| sed -e 's/createLink:/p:0\&\&/' \
	| sed -e 's/+ stackTrace()/+0/' \
	| sed -e 's/this.errno = errno/if(errno==44)this.code="ENOENT";&/' \
	| sed -e "s/ready();/exports.ver=$rev;exports.run=callMain;exports.FS=FS;Object.freeze(exports);/" \
	| sed -re 's/(mmap|msync|ioctl|munmap|rename|syncfs|doDup|calculateAt|doStat|doMsync|doMkdir|doMknod|doReadlink|doAccess|quit):/&0\&\&/' \
	| sed -e 's/ErrnoError/Eno/' \
	| sed -e 's/web_user/diegocr/' \
	| sed -e 's/this.program/dcraw/' > dcraw.tmp.js

cat <<EOF >>dcraw.tmp.js
function callMain(args) {
 var argc = args.length + 1;
 var argv = _malloc((argc + 1) * 4);
 HEAP32[argv >> 2] = allocateUTF8('dcraw');
 for (var i = 1; i < argc; i++) {
  HEAP32[(argv >> 2) + i] = allocateUTF8(args[i - 1]);
 }
 HEAP32[(argv >> 2) + argc] = 0;
 return _main(argc, argv);
}
EOF

uglifyjs -c pure_getters=true,passes=4 -b indent_level=1,width=8192,ascii_only --wrap=dcraw --stats --screw-ie8 -o dcraw.tmpx.js dcraw.tmp.js
cat ./LICENSE.txt dcraw.tmpx.js > dcraw.js

rm -v dcraw.tmp*
