#!/bin/bash

# 字体安装脚本
# 将当前目录下的所有.ttf文件安装到系统字体目录

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查当前用户权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}警告：需要root权限来安装系统字体${NC}"
        echo -e "请使用sudo运行此脚本：${GREEN}sudo ./install_fonts.sh${NC}"
        exit 1
    fi
}

# 检查并创建字体目录
setup_fonts_dir() {
    # 系统字体目录
    SYSTEM_FONT_DIR="/usr/share/fonts/truetype/custom"
    
    echo -e "${GREEN}设置字体目录...${NC}"
    
    # 创建自定义字体目录
    if [ ! -d "$SYSTEM_FONT_DIR" ]; then
        echo "创建字体目录: $SYSTEM_FONT_DIR"
        mkdir -p "$SYSTEM_FONT_DIR"
    fi
    
    # 创建用户字体目录（备用）
    USER_FONT_DIR="$HOME/.local/share/fonts"
    if [ ! -d "$USER_FONT_DIR" ]; then
        echo "创建用户字体目录: $USER_FONT_DIR"
        mkdir -p "$USER_FONT_DIR"
    fi
}

# 查找TTF文件
find_ttf_files() {
    echo -e "${GREEN}查找TTF字体文件...${NC}"
    
    # 查找当前目录及子目录中的所有.ttf文件
    ttf_files=$(find . -name "*.ttf" -type f)
    
    if [ -z "$ttf_files" ]; then
        echo -e "${RED}未找到任何.ttf字体文件！${NC}"
        echo "请在包含.ttf文件的目录中运行此脚本"
        exit 1
    fi
    
    echo "找到以下字体文件："
    echo "---------------------"
    echo "$ttf_files"
    echo "---------------------"
    
    # 统计数量
    count=$(echo "$ttf_files" | wc -l)
    echo -e "共找到 ${YELLOW}$count${NC} 个字体文件"
    
    read -p "是否继续安装？[Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo "安装已取消"
        exit 0
    fi
}

# 安装字体到系统目录
 () {
    local ttf_files=$1
    SYSTEM_FONT_DIR="/usr/share/fonts/truetype/custom"
    
    echo -e "${GREEN}正在安装字体到系统目录...${NC}"
    
    # 复制所有ttf文件到系统字体目录
    echo "$ttf_files" | while read -r font; do
        filename=$(basename "$font")
        echo "安装: $filename"
        cp "$font" "$SYSTEM_FONT_DIR/"
    done
    
    # 更新字体缓存
    echo -e "${GREEN}更新字体缓存...${NC}"
    fc-cache -f -v
    
    echo -e "${GREEN}✅ 字体安装完成！${NC}"
    echo "字体已安装到: $SYSTEM_FONT_DIR"
}

# 安装字体到用户目录（不需要root权限）
install_to_user() {
    local ttf_files=$1
    USER_FONT_DIR="$HOME/.local/share/fonts"
    
    echo -e "${GREEN}正在安装字体到用户目录...${NC}"
    
    # 复制所有ttf文件到用户字体目录
    echo "$ttf_files" | while read -r font; do
        filename=$(basename "$font")
        echo "安装: $filename"
        cp "$font" "$USER_FONT_DIR/"
    done
    
    # 更新用户字体缓存
    echo -e "${GREEN}更新用户字体缓存...${NC}"
    fc-cache -f -v --user-only
    
    echo -e "${GREEN}✅ 字体安装完成！${NC}"
    echo "字体已安装到: $USER_FONT_DIR"
    echo "注意：用户字体只对当前用户生效"
}

# 验证安装
verify_installation() {
    echo -e "${GREEN}验证字体安装...${NC}"
    
    # 列出新安装的字体
    echo "最近安装的字体："
    fc-list | grep -i "custom" || fc-list | tail -20
    
    # 测试字体缓存
    echo -e "\n${GREEN}字体缓存状态：${NC}"
    fc-cache --verbose | tail -10
    
    echo -e "\n${GREEN}✅ 安装验证完成！${NC}"
    echo "你可能需要重启应用程序才能看到新字体"
}

# 显示使用说明
show_help() {
    echo -e "${GREEN}字体安装脚本使用说明${NC}"
    echo "========================="
    echo "功能：安装当前目录下的所有.ttf字体文件"
    echo ""
    echo "使用方法："
    echo "  1. 系统安装（需要root权限）："
    echo "     sudo ./install_fonts.sh"
    echo ""
    echo "  2. 用户安装（不需要root权限）："
    echo "     ./install_fonts.sh --user"
    echo ""
    echo "  3. 仅安装特定字体："
    echo "     ./install_fonts.sh font1.ttf font2.ttf"
    echo ""
    echo "  4. 显示帮助："
    echo "     ./install_fonts.sh --help"
    echo ""
    echo "选项："
    echo "  --user    安装到用户目录 (~/.local/share/fonts)"
    echo "  --system  安装到系统目录 (需要root权限)"
    echo "  --help    显示此帮助信息"
}

# 主函数
main() {
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}      TTF字体安装脚本            ${NC}"
    echo -e "${GREEN}=================================${NC}"
    
    # 处理参数
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    # 设置字体目录
    setup_fonts_dir
    
    # 查找TTF文件
    ttf_files=$(find . -name "*.ttf" -type f)
    
    if [ -z "$ttf_files" ]; then
        echo -e "${RED}错误：未找到任何.ttf字体文件！${NC}"
        echo "请在包含.ttf文件的目录中运行此脚本"
        exit 1
    fi
    
    # 显示找到的字体文件
    count=$(echo "$ttf_files" | wc -l)
    echo -e "找到 ${YELLOW}$count${NC} 个字体文件："
    echo "$ttf_files"
    echo ""
    
    # 根据参数选择安装方式
    if [[ "$1" == "--user" ]]; then
        # 用户安装模式
        install_to_user "$ttf_files"
    elif [[ "$1" == "--system" ]] || [[ $EUID -eq 0 ]]; then
        # 系统安装模式
        if [[ $EUID -ne 0 ]]; then
            echo -e "${RED}错误：系统安装需要root权限${NC}"
            echo "请使用: sudo ./install_fonts.sh --system"
            exit 1
        fi
        install_to_system "$ttf_files"
    else
        # 交互式选择
        echo -e "${YELLOW}请选择安装方式：${NC}"
        echo "1) 安装到系统目录（需要root权限）"
        echo "2) 安装到用户目录（仅当前用户可用）"
        echo "3) 取消"
        read -p "请选择 [1-3]: " choice
        
        case $choice in
            1)
                if [[ $EUID -ne 0 ]]; then
                    echo -e "${RED}需要root权限，请使用sudo重新运行${NC}"
                    exit 1
                fi
                install_to_system "$ttf_files"
                ;;
            2)
                install_to_user "$ttf_files"
                ;;
            3)
                echo "安装已取消"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                exit 1
                ;;
        esac
    fi
    
    # 验证安装
    verify_installation
    
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}     字体安装完成！              ${NC}"
    echo -e "${GREEN}=================================${NC}"
    echo ""
    echo "提示："
    echo "  - 如果字体不显示，请尝试重启应用程序"
    echo "  - 可以使用命令 'fc-list' 查看所有已安装字体"
    echo "  - 可以使用命令 'fc-cache -f -v' 强制刷新字体缓存"
}

# 运行主函数
main "$@"