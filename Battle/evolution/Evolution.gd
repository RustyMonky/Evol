extends Container

var current_choice = 0

var evolutions = [
    {
        name: "Defense",
        desc: "Relies on battles of attrition and endurance"
    },
    {
        name: "Speed",
        desc: "Evolved to end battles quickly and decisively"
    },
    {
        name: "Strength",
        desc: "Depends on its overwhelming power"
    },
    {
        name: "Fire",
        desc: "Attuned to the flames, burning all in its path"
    },
    {
        name: "Water",
        desc: "A viscous and flexible form to flood the world"
    },
    {
        name: "Plant",
        desc: "A mimicry of flora, poised to trap its foes"
    }
]

func _ready():
    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_left"):
        if current_option - 1 < 0:
            current_option = 5
        else:
            current_option -= 1
        update_labels_and_pointer()

    elif event.is_action_pressed("ui_right"):
        if current_option + 1 > 5:
            current_option = 0
        else:
            current_option += 1
        update_labels_and_pointer()

func update_labels_and_pointer():
    $vBox/formName.set_text(evolutions[current_choice].name)
    $vBox/formDesc.set_text(evolutions[current_choice].desc)
    