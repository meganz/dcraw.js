#!/bin/bash

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

emcc -Oz -g1 --llvm-lto 3 -s ASM_JS=1 -s INVOKE_RUN=0 -s NO_EXIT_RUNTIME=1 -s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORT_NAME=\"DCRawMod\" -s NO_DYNAMIC_EXECUTION=1 -s DISABLE_EXCEPTION_CATCHING=1 -s MEMFS_APPEND_TO_TYPED_ARRAYS=1 \
	-s WARN_ON_UNDEFINED_SYMBOLS=0 -s DEFAULT_LIBRARY_FUNCS_TO_INCLUDE="['memcpy','memset','malloc','free','strlen']" \
	-s USE_SDL=0 -s AGGRESSIVE_VARIABLE_ELIMINATION=0 -s DOUBLE_MODE=0 -s PRECISE_I64_MATH=0 -s MEM_INIT_METHOD=2 \
	-o dcraw.js -DNODEPS -Wno-warn-absolute-paths dcraw.tmp.c \
	--memory-init-file 0

cat dcraw.js \
	| sed -re 's/(var )?ENVIRONMENT_IS_\w+ =/\/\/off/' \
	| sed -e 's/ENVIRONMENT_IS_NODE/0/' \
	| sed -e 's/ENVIRONMENT_IS_SHELL/0/' \
	| sed -e 's/ENVIRONMENT_IS_WORKER/0/' \
	| sed -e 's/ENVIRONMENT_IS_WEB/1/' \
	| sed -e 's/typeof console/self.d\&\&&/' \
	| sed -e 's/Browser.initted/1/' \
	| sed -re 's/^Module\["(\w+)"\] = \1;/\/\/&/' \
	| sed -re 's/Module\["(read|ENVI|extraStac|noInitialRun|onRuntimeIni|setStatus|setWindo|load|argum|preInit)/1\?0\:&/' \
	| sed -re 's/^Module\["(FS|preloadedImages|preloadedAudios|exit|abort|run|noExitR)/\/\/&/' \
	| sed -re 's/^Module\["(\w+)"\] = Module\.\1/Module.\1/' \
	| sed -re 's/^Module\.(\w.*) = Module\["\1"\]/Module.\1/' \
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
	| sed -e 's/calledMain = true;//' \
	| sed -e 's/&& shouldRunNow/\&\&0/' \
	| sed -e 's/var cwrap, ccall;/if(0)/' \
	| sed -e 's/exit(ret, true);/if(0)&/' \
	| sed -e 's/e instanceof ExitStatus/0/' \
	| sed -e 's/^ExitStatus/\/\/&/' \
	| sed -e 's/e == "SimulateInfiniteLoop"/0/' \
	| sed -e 's/+ stackTrace()/+0/' \
	| sed -e 's/: abortOnCannotGrowMemory/: abort.bind(0,-2)/' \
	| sed -e 's-var runDependencies-//&-' \
	| sed -e 's-runDependencies-1?0:&-' \
	| sed -e 's-preloadStartTime ==-1?0:&-' \
	| sed -e 's-var memoryInitializer-//&-' \
	| sed -e 's-memoryInitializer =-var &-' \
	| sed -e 's/for (i = 0; i < n; ++i) {/for (var i = s.length; i--;) {/' \
	| sed -e 's/function abort(/function abort(e){throw new Error(e)}if(0)var _=&/' \
	| sed -re 's/(mmap|msync|ioctl|munmap|rename|syncfs):/&0\&\&/' \
	| sed -e 's/TOTAL_MEMORY < TOTAL_STACK/0/' \
	| sed -e 's/^dependenciesFulfilled/if(0)&/' \
	| sed -e 's/assert(!FS.init.initialized/if(0)&/' \
	| sed -e 's/ERRNO_CODES/ENO/' \
	| sed -e 's/ERRNO_MESSAGES/EME/' \
	| sed -e 's/ErrnoError/Eno/' \
	| sed -re 's/Module\["UTF8ToString"\]\(ptr\)/UTF8ArrayToString(HEAPU8,ptr)/' \
	| sed -re 's/function (demangle|addRunDependency|removeRunDependency)/if(0) var __R=&/' \
	| sed -re 's/function (_recv|_send)/function \1\(\)\{\};if(0) var __R=&/' \
	| sed -e 's/demangleAll//' \
	| sed -e 's/var SOCKFS/if(0)&/' \
	| sed -e 's/ SOCKFS.root/\/\/&/' \
	| sed -e 's/var WORKERFS/if(0)&/' \
	| sed -e 's/var NODEFS/if(0)&/' \
	| sed -e 's/var IDBFS/if(0)&/' \
	| sed -e 's/var Browser/if(0)&/' \
	| sed -e 's/var i64Math/if(0) var UYDgkasj/' \
	| sed -e 's/i64Math/0/' \
	| sed -e 's/web_user/diegocr/' \
	| sed -e 's/postRun();/else run=Module\.callMain;&/' \
	| sed -e 's/this.program/dcraw/' > dcraw.tmp.js

rev=$(grep \$Revision dcraw.c | awk '{ print $2 }')

echo "exports.ver=$rev;exports.run=run;exports.FS=FS;Object.freeze(exports);" >> dcraw.tmp.js

# uglifyjs -m -c --wrap=dcraw --stats --screw-ie8 -o dcraw.tmpx.js dcraw.tmp.js
# cat ./LICENSE.txt dcraw.tmpx.js > dcraw.min.js

uglifyjs -c pure_getters=true,passes=4 -b indent_level=1,width=8192,ascii_only --wrap=dcraw --stats --screw-ie8 -o dcraw.tmpx.js dcraw.tmp.js
cat ./LICENSE.txt dcraw.tmpx.js > dcraw.js

rm -v dcraw.tmp*
