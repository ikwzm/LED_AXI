/*********************************************************************************
 *
 *       Copyright (C) 2014-2015 Ichiro Kawazome
 *       All rights reserved.
 * 
 *       Redistribution and use in source and binary forms, with or without
 *       modification, are permitted provided that the following conditions
 *       are met:
 * 
 *         1. Redistributions of source code must retain the above copyright
 *            notice, this list of conditions and the following disclaimer.
 * 
 *         2. Redistributions in binary form must reproduce the above copyright
 *            notice, this list of conditions and the following disclaimer in
 *            the documentation and/or other materials provided with the
 *            distribution.
 * 
 *       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
 *       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 *       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 ********************************************************************************/
#include <linux/cdev.h>
#include <linux/clk.h>
#include <linux/dma-mapping.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/ioport.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/of.h>
#include <linux/sched.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/sysctl.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/scatterlist.h>
#include <linux/pagemap.h>
#include <linux/list.h>
#include <linux/version.h>
#include <linux/spinlock.h>
#include <asm/page.h>
#include <asm/byteorder.h>


#define DRIVER_NAME        "zled"
#define DEVICE_NAME_FORMAT "zled%d"

#if     (LINUX_VERSION_CODE >= 0x030B00)
#define USE_DEV_GROUPS      1
#else
#define USE_DEV_GROUPS      0
#endif

static struct class*  zled_sys_class     = NULL;
static dev_t          zled_device_number = 0;

/**
 *  Register read/write access routines
 */
#define regs_write(offset, val)	__raw_writel(cpu_to_le32(val), offset)
#define regs_read(offset)       le32_to_cpu(__raw_readl(offset))

/**
 * struct zled_driver_data - Device driver structure
 */
struct zled_driver_data {
    struct device*       dev;
    struct device*       sys_device;
    struct cdev          cdev;
    dev_t                device_number;
    struct mutex         sem;
    struct resource*     regs_res;
    bool                 is_open;
    void __iomem*        regs_addr;
    unsigned int         out;
    unsigned int         seq0;
    unsigned int         seq1;
    unsigned int         seq2;
    unsigned int         seq3;
    unsigned int         seq4;
    unsigned int         seq5;
    unsigned int         seqlast;
    unsigned int         count;
    bool                 start;
};

/**
 *
 */
static int zled_write_regs(struct zled_driver_data* this, unsigned int num)
{
    u32 regs_value;
    if (num == 0) {
        regs_value = ((this->out  & 0xF) <<  0) |
                     ((this->seq0 & 0xF) <<  8) |
                     ((this->seq1 & 0xF) << 12) |
                     ((this->seq2 & 0xF) << 16) |
                     ((this->seq3 & 0xF) << 20) |
                     ((this->seq4 & 0xF) << 24) |
                     ((this->seq5 & 0xF) << 28);
        regs_write(this->regs_addr+0, regs_value);
    } else {
        regs_value = ((this->count   & 0x0FFFFFFF) <<  0) |
                     ((this->seqlast & 0x7       ) << 28) |
                     ((this->start   & 0x1       ) << 31);
        regs_write(this->regs_addr+4, regs_value);
    }
    return 0;
}

#define DEF_ATTR_SHOW(__attr_name, __format, __value) \
static ssize_t zled_show_ ## __attr_name(struct device *dev, struct device_attribute *attr, char *buf) \
{ \
    ssize_t status;                                       \
    struct zled_driver_data* this = dev_get_drvdata(dev); \
    if (mutex_lock_interruptible(&this->sem) != 0)        \
        return -ERESTARTSYS;                              \
    status = sprintf(buf, __format, (__value));           \
    mutex_unlock(&this->sem);                             \
    return status;                                        \
}

#define DEF_ATTR_SET(__attr_name, __min, __max, __pre_action, __post_action) \
static ssize_t zled_set_ ## __attr_name(struct device *dev, struct device_attribute *attr, const char *buf, size_t size) \
{ \
    ssize_t       status; \
    unsigned long value;  \
    struct zled_driver_data* this = dev_get_drvdata(dev);                    \
    if (0 != mutex_lock_interruptible(&this->sem)){return -ERESTARTSYS;}     \
    if (0 != (status = kstrtoul(buf, 10, &value))){            goto failed;} \
    if ((value < __min) || (__max < value)) {status = -EINVAL; goto failed;} \
    if (0 != (status = __pre_action )) {                       goto failed;} \
    this->__attr_name = value;                                               \
    if (0 != (status = __post_action)) {                       goto failed;} \
    status = size;                                                           \
  failed:                                                                    \
    mutex_unlock(&this->sem);                                                \
    return status;                                                           \
}

DEF_ATTR_SHOW(out    , "%d\n", this->out    );
DEF_ATTR_SHOW(seq0   , "%d\n", this->seq0   );
DEF_ATTR_SHOW(seq1   , "%d\n", this->seq1   );
DEF_ATTR_SHOW(seq2   , "%d\n", this->seq2   );
DEF_ATTR_SHOW(seq3   , "%d\n", this->seq3   );
DEF_ATTR_SHOW(seq4   , "%d\n", this->seq4   );
DEF_ATTR_SHOW(seq5   , "%d\n", this->seq5   );
DEF_ATTR_SHOW(seqlast, "%d\n", this->seqlast);
DEF_ATTR_SHOW(count  , "%d\n", this->count  );
DEF_ATTR_SHOW(start  , "%d\n", this->start  );

DEF_ATTR_SET( out    , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq0   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq1   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq2   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq3   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq4   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seq5   , 0,        0xF, 0, (zled_write_regs(this,0)));
DEF_ATTR_SET( seqlast, 0,          5, 0, (zled_write_regs(this,1)));
DEF_ATTR_SET( count  , 0, 0x0FFFFFFF, 0, (zled_write_regs(this,1)));
DEF_ATTR_SET( start  , 0,          1, 0, (zled_write_regs(this,1)));

static struct device_attribute zled_device_attrs[] = {
  __ATTR(out    , 0644, zled_show_out    , zled_set_out    ),
  __ATTR(start  , 0644, zled_show_start  , zled_set_start  ),
  __ATTR(seq0   , 0644, zled_show_seq0   , zled_set_seq0   ),
  __ATTR(seq1   , 0644, zled_show_seq1   , zled_set_seq1   ),
  __ATTR(seq2   , 0644, zled_show_seq2   , zled_set_seq2   ),
  __ATTR(seq3   , 0644, zled_show_seq3   , zled_set_seq3   ),
  __ATTR(seq4   , 0644, zled_show_seq4   , zled_set_seq4   ),
  __ATTR(seq5   , 0644, zled_show_seq5   , zled_set_seq5   ),
  __ATTR(seqlast, 0644, zled_show_seqlast, zled_set_seqlast),
  __ATTR(count  , 0644, zled_show_count  , zled_set_count  ),
  __ATTR_NULL,
};

#if (USE_DEV_GROUPS == 1)

static struct attribute *zled_attrs[] = {
  &(zled_device_attrs[0].attr),
  &(zled_device_attrs[1].attr),
  &(zled_device_attrs[2].attr),
  &(zled_device_attrs[3].attr),
  &(zled_device_attrs[4].attr),
  &(zled_device_attrs[5].attr),
  &(zled_device_attrs[6].attr),
  &(zled_device_attrs[7].attr),
  &(zled_device_attrs[8].attr),
  &(zled_device_attrs[9].attr),
  NULL
};
static struct attribute_group  zled_attr_group = {
  .attrs = zled_attrs
};
static const struct attribute_group* zled_attr_groups[] = {
  &zled_attr_group,
  NULL
};

#define SET_SYS_CLASS_ATTRIBUTES(sys_class) {(sys_class)->dev_groups = zled_attr_groups; }
#else
#define SET_SYS_CLASS_ATTRIBUTES(sys_class) {(sys_class)->dev_attrs  = zled_device_attrs;}
#endif

/**
 * zled_open() - The is the driver open function.
 * @inode:	Pointer to the inode structure of this device.
 * @file:	Pointer to the file structure.
 * returns:	Success or error status.
 */
static int zled_open(struct inode *inode, struct file *file)
{
    struct zled_driver_data* driver_data;
    int status = 0;

    driver_data = container_of(inode->i_cdev, struct zled_driver_data, cdev);
    file->private_data   = driver_data;
    driver_data->is_open = 1;

    return status;
}
/**
 * zled_release() - The is the driver release function.
 * @inode:	Pointer to the inode structure of this device.
 * @file:	Pointer to the file structure.
 * returns:	Success.
 */
static int zled_release(struct inode *inode, struct file *file)
{
    struct zled_driver_data* driver_data = file->private_data;

    driver_data->is_open = 0;

    return 0;
}

/**
 *
 */
static const struct file_operations zled_driver_fops = {
    .owner   = THIS_MODULE,
    .open    = zled_open,
    .release = zled_release,
};

/**
 * zled_driver_probe() -  Probe call for the device.
 *
 * @pdev:	handle to the platform device structure.
 * Returns 0 on success, negative error otherwise.
 *
 * It does all the memory allocation and registration for the device.
 */
static int zled_driver_probe(struct platform_device *pdev)
{
    struct zled_driver_data*    this     = NULL;
    int                         retval   = 0;
    unsigned int                done     = 0;
    const unsigned int          DONE_CHRDEV_ADD    = (1 << 0);
    const unsigned int          DONE_REGS_RESOUCE  = (1 << 1);
    const unsigned int          DONE_MEM_REGION    = (1 << 2);
    const unsigned int          DONE_MAP_REGS_ADDR = (1 << 3);
    const unsigned int          DONE_DEVICE_CREATE = (1 << 4);
    unsigned long               regs_addr = 0L;
    unsigned long               regs_size = 0L;

    dev_info(&pdev->dev, "ZLED Driver probe start\n");
    /*
     * create (zled_driver_data*)this.
     */
    {
        this = kzalloc(sizeof(*this), GFP_KERNEL);
        if (IS_ERR_OR_NULL(this)) {
            dev_err(&pdev->dev, "couldn't allocate device private record\n");
            retval = PTR_ERR(this);
            this = NULL;
            goto failed;
        }
        dev_set_drvdata(&pdev->dev, this);
        this->dev = &pdev->dev;
    }
    /*
     * make this->device_number
     */
    {
        this->device_number = MKDEV(MAJOR(zled_device_number),0);
    }
    /*
     * get register resouce and ioremap to this->regs_addr.
     */
    {
        this->regs_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
        if (this->regs_res == NULL) {
            dev_err(this->dev, "invalid register address\n");
            retval = -ENODEV;
            goto failed;
        }
        done |= DONE_REGS_RESOUCE;
        regs_addr = this->regs_res->start;
        regs_size = this->regs_res->end - this->regs_res->start + 1;

        if (request_mem_region(regs_addr, regs_size, DRIVER_NAME) == NULL) {
            dev_err(this->dev, "couldn't lock memory region at %pr\n", this->regs_res);
            retval = -EBUSY;
            goto failed;
        }
        done |= DONE_MEM_REGION;

        this->regs_addr = ioremap_nocache(regs_addr, regs_size);
        if (this->regs_addr == NULL) {
          dev_err(this->dev, "ioremap(%pr) failed\n", this->regs_res);
            goto failed;
        }
        done |= DONE_MAP_REGS_ADDR;
    }
    /*
     * register sys/class/zled/zled0
     */
    {
        this->sys_device = device_create(zled_sys_class,
                                         NULL,
                                         this->device_number,
                                         (void *)this,
                                         DEVICE_NAME_FORMAT, MINOR(this->device_number));
        if (IS_ERR_OR_NULL(this->sys_device)) {
            dev_err(this->dev, "device_create() failed\n");
            retval = PTR_ERR(this->sys_device);
            this->sys_device = NULL;
            goto failed;
        }
        done |= DONE_DEVICE_CREATE;
    }
    /*
     * add chrdev.
     */
    {
        cdev_init(&this->cdev, &zled_driver_fops);
        this->cdev.owner = THIS_MODULE;
        if (cdev_add(&this->cdev, this->device_number, 1) != 0) {
            dev_err(this->dev, "cdev_add() failed\n");
            retval = -ENODEV;
            goto failed;
        }
        done |= DONE_CHRDEV_ADD;
    }
    /*
     *
     */
    mutex_init(&this->sem);
    /*
     *
     */
    {
        u32 regs_value[2];
        regs_value[0] = regs_read(this->regs_addr+0);
        regs_value[1] = regs_read(this->regs_addr+4);
        this->out     = (regs_value[0] >>  0) & 0xF;
        this->seq0    = (regs_value[0] >>  8) & 0xF;
        this->seq1    = (regs_value[0] >> 12) & 0xF;
        this->seq2    = (regs_value[0] >> 16) & 0xF;
        this->seq3    = (regs_value[0] >> 20) & 0xF;
        this->seq4    = (regs_value[0] >> 24) & 0xF;
        this->seq5    = (regs_value[0] >> 28) & 0xF;
        this->count   = (regs_value[1]      ) & 0x0FFFFFFF;
        this->seqlast = (regs_value[1] >> 28) & 0x7;
        this->start   = (regs_value[1] >> 31) & 0x1;
    }
    /*
     *
     */
    dev_info(this->sys_device, "driver installed\n");
    dev_info(this->sys_device, "private record = %pK (%dbytes)\n", this, sizeof(*this));
    dev_info(this->sys_device, "major number   = %d\n"           , MAJOR(this->device_number));
    dev_info(this->sys_device, "regs resource  = %pr\n"          , this->regs_res );
    dev_info(this->sys_device, "regs address   = %pK\n"          , this->regs_addr);
    dev_info(this->sys_device, "regs out       = %01X\n"         , this->out);
    dev_info(this->sys_device, "regs seq0      = %01X\n"         , this->seq0);
    dev_info(this->sys_device, "regs seq1      = %01X\n"         , this->seq1);
    dev_info(this->sys_device, "regs seq2      = %01X\n"         , this->seq2);
    dev_info(this->sys_device, "regs seq3      = %01X\n"         , this->seq3);
    dev_info(this->sys_device, "regs seq4      = %01X\n"         , this->seq4);
    dev_info(this->sys_device, "regs seq5      = %01X\n"         , this->seq5);
    dev_info(this->sys_device, "regs seqlast   = %d\n"           , this->seqlast);
    dev_info(this->sys_device, "regs count     = %d\n"           , this->count);
    dev_info(this->sys_device, "regs start     = %d\n"           , this->start);

    return 0;

 failed:
    if (done & DONE_DEVICE_CREATE) { device_destroy(zled_sys_class, this->device_number);}
    if (done & DONE_MAP_REGS_ADDR) { iounmap(this->regs_addr); }
    if (done & DONE_MEM_REGION   ) { release_mem_region(regs_addr, regs_size);}
    if (done & DONE_CHRDEV_ADD   ) { cdev_del(&this->cdev); }
    if (this != NULL)              { kfree(this); }
    return retval;
}


/**
 * zled_driver_remove() -  Remove call for the device.
 *
 * @pdev:	handle to the platform device structure.
 * Returns 0 or error status.
 *
 * Unregister the device after releasing the resources.
 */
static int zled_driver_remove(struct platform_device *pdev)
{
    struct zled_driver_data* this  = dev_get_drvdata(&pdev->dev);

    if (!this)
        return -ENODEV;

    device_destroy(zled_sys_class, this->device_number);
    iounmap(this->regs_addr);
    release_mem_region(this->regs_res->start, this->regs_res->end - this->regs_res->start + 1);
    cdev_del(&this->cdev);
    kfree(this);
    dev_set_drvdata(&pdev->dev, NULL);
    dev_info(&pdev->dev, "driver unloaded\n");
    return 0;
}

/**
 * Open Firmware Device Identifier Matching Table
 */
static struct of_device_id zled_of_match[] = {
    { .compatible = "ikwzm,zled-0.10.a", },
    { /* end of table */}
};

MODULE_DEVICE_TABLE(of, zled_of_match);

/**
 * Platform Driver Structure
 */
static struct platform_driver zled_platform_driver = {
    .probe  = zled_driver_probe,
    .remove = zled_driver_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name  = DRIVER_NAME,
        .of_match_table = zled_of_match,
    },
};

/**
 * zled_module_init()
 */
static int __init zled_module_init(void)
{
    int                retval = 0;
    unsigned int       done   = 0;
    const unsigned int DONE_CHRDEV_ALLOC    = (1 << 0);
    const unsigned int DONE_CLASS_CREATE    = (1 << 1);
    const unsigned int DONE_DRIVER_REGISTER = (1 << 2);

    retval = alloc_chrdev_region(&zled_device_number, 0, 0, DRIVER_NAME);
    if (retval != 0) {
        printk(KERN_ERR "%s: couldn't allocate device major number\n", DRIVER_NAME);
        goto failed;
    }
    done |= DONE_CHRDEV_ALLOC;

    zled_sys_class = class_create(THIS_MODULE, DRIVER_NAME);
    if (IS_ERR_OR_NULL(zled_sys_class)) {
        printk(KERN_ERR "%s: couldn't create sys class\n", DRIVER_NAME);
        retval = PTR_ERR(zled_sys_class);
        zled_sys_class = NULL;
        goto failed;
    }
    SET_SYS_CLASS_ATTRIBUTES(zled_sys_class);
    done |= DONE_CLASS_CREATE;

    retval = platform_driver_register(&zled_platform_driver);
    if (retval) {
        printk(KERN_ERR "%s: couldn't register platform driver\n", DRIVER_NAME);
        goto failed;
    }
    done |= DONE_DRIVER_REGISTER;

    return 0;

 failed:
    if (done & DONE_DRIVER_REGISTER){platform_driver_unregister(&zled_platform_driver);}
    if (done & DONE_CLASS_CREATE   ){class_destroy(zled_sys_class);}
    if (done & DONE_CHRDEV_ALLOC   ){unregister_chrdev_region(zled_device_number, 0);}

    return retval;
}

/**
 * zled_module_exit()
 */
static void __exit zled_module_exit(void)
{
    platform_driver_unregister(&zled_platform_driver);
    class_destroy(zled_sys_class);
    unregister_chrdev_region(zled_device_number, 0);
}


module_init(zled_module_init);
module_exit(zled_module_exit);

MODULE_AUTHOR("ikwzm");
MODULE_DESCRIPTION("ZYNQ-LED Driver");
MODULE_LICENSE("GPL");

