# 初始化
import imgui, config
using imgui
var app=fullscreen_application(0, "Display Board v1.0")
#var app=window_application(1920, 1080, "Display Board v1.0")
var logo=load_bmp_image(config.resource_directory+system.path.separator+config.logo_name)
var about=load_bmp_image(config.resource_directory+system.path.separator+config.about_name)
var font=add_font_chinese(config.resource_directory+system.path.separator+config.font_name, config.font_size)
# 布局信息
namespace layout
    var menu_offset =54
    var column_0    =0.25*app.get_window_width(), column_1=0.75*app.get_window_width()
    var row_0       =column_0
    var row_1       =(app.get_window_height()-row_0-menu_offset)/2
    var row_2       =row_1
    var row_3       =app.get_window_height()-menu_offset
    var size_0      =vec2(column_0, row_0)
    var size_0_pic  =vec2(column_0-16, row_0-16)
    var size_1      =vec2(column_0, row_1)
    var size_2      =vec2(column_0, row_2)
    var size_3      =vec2(column_1, row_3)
    var pic_radio   =about.get_width()/about.get_height()
    var size_4      =vec2(pic_radio*app.get_window_height()*0.1+100, app.get_window_height()*0.1)
    var size_4_pic  =vec2(pic_radio*(app.get_window_height()*0.1-16), app.get_window_height()*0.1-16)
    var size_4_t_wid=pic_radio*app.get_window_height()*0.1+100-pic_radio*(app.get_window_height()*0.1-16)-16
    var pos_0       =vec2(0, menu_offset)
    var pos_1       =vec2(0, menu_offset+row_0)
    var pos_2       =vec2(0, menu_offset+row_0+row_1)
    var pos_3       =vec2(column_0, menu_offset)
    var pos_4       =vec2(app.get_window_width()-(pic_radio*app.get_window_height()*0.1+100), app.get_window_height()*0.9)
end
# 加载教师信息
struct teacher_profile
    var name=null
    var photo=null
    var p_size=null
    var p_width=null
    var introduce=null
end
var teacher_profiles=new array
block
    var dirs=system.path.scan(config.config_directory+system.path.separator+config.teacher_profile)
    foreach it in dirs
        if it.type()==system.path.type.dir&&it.name()!="."&&it.name()!=".."&&it.name()!="default"
            var path=config.config_directory+system.path.separator+config.teacher_profile+system.path.separator+it.name()
            var conf=context.import(path, "layout")
            var prof=gcnew teacher_profile
            prof->name=conf.name
            prof->photo=load_bmp_image(path+system.path.separator+conf.photo)
            var radio=(layout.row_1-16)/prof->photo.get_height()
            prof->p_size=vec2(radio*prof->photo.get_width(), radio*prof->photo.get_height())
            prof->p_width=radio*prof->photo.get_width()
            prof->introduce=conf.introduce
            teacher_profiles.push_back(prof)
        end
    end
end
# 加载场景信息
var scene_profiles=new array
block
    var dirs=system.path.scan(config.config_directory+system.path.separator+config.scene_profile)
    foreach it in dirs
        if it.type()==system.path.type.dir&&it.name()!="."&&it.name()!=".."&&it.name()!="default"
            var path=config.config_directory+system.path.separator+config.scene_profile+system.path.separator+it.name()
            var conf=context.import(path, "layout")
            var prof=gcnew conf.scene
            prof->gui=imgui
            prof->root_path=path
            prof->init()
            scene_profiles.push_back(prof)
        end
    end
end
# 窗口布局
function window_logo()
    set_window_size(layout.size_0)
    set_window_pos(layout.pos_0)
    image(logo, layout.size_0_pic)
end
var offset_0=0, clock_0=runtime.time(), switch_clk_0=3000
function window_activity()
    set_window_size(layout.size_1)
    set_window_pos(layout.pos_1)
    text(config.activity_list.at(offset_0).first())
    indent()
    text_wrappered(config.activity_list.at(offset_0).second())
    if runtime.time()-clock_0>switch_clk_0
        if ++offset_0>=config.activity_list.size()
            offset_0=0
        end
        clock_0=runtime.time()
    end
end
var offset_1=0, clock_1=runtime.time(), switch_clk_1=4000
function window_teacher()
    set_window_size(layout.size_2)
    set_window_pos(layout.pos_2)
    set_window_font_scale(0.7)
    columns(2, "teacher", false)
    set_column_width(0, teacher_profiles.at(offset_1)->p_width)
    image(teacher_profiles.at(offset_1)->photo, teacher_profiles.at(offset_1)->p_size)
    next_column()
    text(teacher_profiles.at(offset_1)->name)
    indent()
    text_wrappered(teacher_profiles.at(offset_1)->introduce)
    next_column()
    if runtime.time()-clock_1>switch_clk_1
        if ++offset_1>=teacher_profiles.size()
            offset_1=0
        end
        clock_1=runtime.time()
    end
end
var offset_2=0, clock_2=runtime.time(), switch_clk_2=5000
function window_scene()
    set_window_size(layout.size_3)
    set_window_pos(layout.pos_3)
    scene_profiles.at(offset_2)->do_layout()
    if runtime.time()-clock_2>switch_clk_2
        if ++offset_2>=scene_profiles.size()
            offset_2=0
        end
        clock_2=runtime.time()
    end
end
function window_about()
    set_window_size(layout.size_4)
    set_window_pos(layout.pos_4)
    set_window_font_scale(0.55)
    set_window_focus()
    columns(2, "about", false)
    set_column_width(0, layout.size_4_t_wid)
    text("智能信息展板")
    text_disabled("川大智锐科创")
    text_disabled("保留所有权利")
    next_column()
    image(about, layout.size_4_pic)
    next_column()
end
# 主程序调度
function window(title, func)
    var window_opened=true
    begin_window(title, window_opened, {flags.no_title_bar, flags.no_resize, flags.no_move, flags.no_collapse, flags.no_saved_settings})
        func()
    end_window()
end
while !app.is_closed()
    app.prepare()
    push_font(font)
    style_color_light()
    if begin_main_menu_bar()
        if menu_item(config.laboratory_name, "", true)
            system.exit(0)
        end
        end_main_menu_bar()
    end
    window("logo", window_logo)
    window("activity", window_activity)
    window("teacher", window_teacher)
    window("scene", window_scene)
    window("about", window_about)
    pop_font()
    app.render()
end