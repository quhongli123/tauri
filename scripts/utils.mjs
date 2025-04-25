/*
 * @Author: 曲洪利 quhongli999@163.com
 * @Date: 2025-04-25 11:29:24
 * @LastEditors: 曲洪利 quhongli999@163.com
 * @LastEditTime: 2025-04-25 11:29:28
 * @FilePath: /tauri-app/scripts/utils.mjs
 * @Description: 
 * 
 * Copyright (c) 2025 by ${git_name_email}, All Rights Reserved. 
 */
import clc from 'cli-color';

export const log_success = (msg, ...optionalParams) =>
  console.log(clc.green(msg), ...optionalParams);
export const log_error = (msg, ...optionalParams) =>
  console.log(clc.red(msg), ...optionalParams);
export const log_info = (msg, ...optionalParams) =>
  console.log(clc.bgBlue(msg), ...optionalParams);
var debugMsg = clc.xterm(245);
export const log_debug = (msg, ...optionalParams) =>
  console.log(debugMsg(msg), ...optionalParams);